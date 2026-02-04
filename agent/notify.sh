#!/bin/bash
# Sends push notification via Pushover
# Requires PUSHOVER_TOKEN and PUSHOVER_USER in .env

if [ -z "$PUSHOVER_TOKEN" ] || [ -z "$PUSHOVER_USER" ]; then
    echo "Warning: PUSHOVER_TOKEN or PUSHOVER_USER not set, skipping notification" >&2
    exit 0
fi

curl -s -X POST https://api.pushover.net/1/messages.json \
  -d "token=$PUSHOVER_TOKEN" \
  -d "user=$PUSHOVER_USER" \
  -d "message=$1" > /dev/null
