#!/bin/bash
# AFK - Runs Claude iteratively to complete GitHub Issues
set -e

[ -f .env ] && export $(grep -v '^#' .env | xargs)

LOG_FILE="agent/afk.log"
PROMPT_FILE="agent/prompt.md"
JQ_STREAM='select(.type == "assistant").message.content[]? | select(.type == "text").text // empty | gsub("\n"; "\r\n") | . + "\r\n\n"'
JQ_RESULT='select(.type == "result").result // empty'

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg"
    echo "$msg" >> "$LOG_FILE"
}

notify() { ./agent/notify.sh "$1" 2>/dev/null || true; }

get_issues_count() { gh issue list --state open --json number 2>/dev/null | jq 'length'; }

if [ -z "$1" ] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "Usage: $0 <iterations>"
    echo "Open issues: $(get_issues_count)"
    exit 1
fi

ITERATIONS="$1"

docker image inspect claude-sandbox &>/dev/null || {
    echo "Error: claude-sandbox image not found."
    echo "Build with: docker build -f Dockerfile -t claude-sandbox ."
    exit 1
}

log "Starting AFK with $ITERATIONS iterations"
log "Open issues: $(get_issues_count)"

trap 'log "AFK interrupted"; notify "AFK interrupted"' INT TERM
trap 'log "AFK errored: $?"; notify "AFK errored"' ERR

for ((i=1; i<=ITERATIONS; i++)); do
    issues=$(gh issue list --state open --json number,title,body,comments)
    open_count=$(get_issues_count)
    afk_commits=$(git log --grep="AFK" -n 10 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || echo "No AFK commits found")

    log "=== Iteration $i/$ITERATIONS === ($open_count issues)"

    if [ "$open_count" -eq 0 ]; then
        log "All issues complete!"
        notify "AFK finished! All issues complete."
        exit 0
    fi

    full_prompt="$issues Previous AFK commits: $afk_commits @$PROMPT_FILE"

    # Run Claude in Docker sandbox
    tmpfile=$(mktemp)
    docker sandbox run --credentials host --template claude-sandbox \
        -e GH_TOKEN="$GH_TOKEN" \
        claude --verbose --print --output-format stream-json "$full_prompt" \
    | grep --line-buffered '^{' \
    | tee "$tmpfile" \
    | jq --unbuffered -rj "$JQ_STREAM" >&2
    result=$(jq -r "$JQ_RESULT" "$tmpfile")
    rm -f "$tmpfile"

    [[ "$result" == *"<promise>COMPLETE</promise>"* ]] && {
        log "Claude signaled complete"
        notify "AFK finished! Claude signaled complete."
        exit 0
    }

    # Handle result markers
    [[ "$result" == *"<blocked"* ]] && {
        reason=$(echo "$result" | sed -n 's/.*<blocked reason="\([^"]*\)".*/\1/p')
        log "Blocked: ${reason:-unknown}"
        notify "AFK blocked: ${reason:-unknown}"
        exit 1
    }
    [[ "$result" == *"You've hit your limit"* ]] && {
        log "Rate limit hit, waiting 1 hour..."
        notify "AFK hit rate limit"
        sleep 3600
        continue
    }
done

log "Ran out of iterations ($ITERATIONS), $(get_issues_count) issues remaining"
notify "AFK ran out of iterations ($(get_issues_count) issues remaining)"
