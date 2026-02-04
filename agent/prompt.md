# ISSUES

Issues JSON is provided at start of context. Parse it to get open issues with their bodies and comments.

You've also been passed a file containing the last 10 AFK commits (SHA, date, full message). Review these to understand what work has been done.

# BLOCKED MARKER

If you cannot proceed, output and STOP immediately:

<blocked reason="..."/>

Examples:
- <blocked reason="need human: design decision required"/>
- <blocked reason="external: waiting on API access"/>

Do not attempt workarounds when blocked.

# TASK BREAKDOWN

Break down the issues into tasks. An issue may contain a single task (a small bugfix or visual tweak) or many, many tasks (a PRD or a large refactor).

Make each task the smallest possible unit of work. We don't want to outrun our headlights. Aim for one small change per task.

# TASK SELECTION

Pick the next task. Prioritize tasks in this order:

1. Critical bugfixes
2. Tracer bullets for new features

Tracer bullets comes from the Pragmatic Programmer. When building systems, you want to write code that gets you feedback as quickly as possible. Tracer bullets are small slices of functionality that go through all layers of the system, allowing you to test and validate your approach early. This helps in identifying potential issues and ensures that the overall architecture is sound before investing significant time in development.

TL;DR - build a tiny, end-to-end slice of the feature first, then expand it out.

3. Polish and quick wins
4. Refactors

If all tasks are complete, output <promise>COMPLETE</promise>.

# EXPLORATION

Explore the repo and fill your context window with relevant information that will allow you to complete the task.

# EXECUTION

Complete the task.

If you find that the task is larger than you expected (for instance, requires a refactor first), output "HANG ON A SECOND".

Then, find a way to break it into a smaller chunk and only do that chunk (i.e. complete the smaller refactor).

# BROWSER VERIFICATION

If you made UI changes, you MUST visually verify the changes render correctly.

1. Start the dev server in background:
   ```bash
   bun dev &
   ```
   Wait for the "Ready" or server startup message.

2. Open the page:
   ```bash
   agent-browser open http://localhost:3000
   ```

3. Take a snapshot to understand page structure (best for AI):
   ```bash
   agent-browser snapshot -i
   ```
   The `-i` flag returns only interactive elements. You get an accessibility tree with refs like `@e1`, `@e2`, etc.

4. Take a screenshot to verify visually:
   ```bash
   agent-browser screenshot /tmp/verify.png
   ```

5. Interact with elements using refs from snapshot:
   ```bash
   agent-browser click @e5
   agent-browser fill @e3 "test input"
   agent-browser press Enter
   ```

6. Wait for navigation or content:
   ```bash
   agent-browser wait --url "**/dashboard"
   agent-browser wait --load networkidle
   ```

7. Close the browser when done:
   ```bash
   agent-browser close
   ```

If something looks wrong, fix it before proceeding.

# FEEDBACK LOOPS

Before committing, run the feedback loops:

- `bun run typecheck` to run the type checker
- `bun run lint` to run the linter
- `bun run test` to run the tests
- `bun run test:e2e` to run e2e tests

# COMMIT

Make a git commit. The commit message must:

1. Start with `AFK:` prefix
2. Include task completed + issue reference
3. Key decisions made
4. Files changed
5. Blockers or notes for next iteration

Keep it concise.

# PROGRESS

After committing, append to progress.txt:

- Task completed and issue reference
- Key decisions made
- Files changed
- Blockers or notes for next iteration

Keep entries concise.

# THE ISSUE

If the task is complete, close the original GitHub issue.

If the task is not complete, leave a comment on the GitHub issue with what was done.

# FINAL RULES

ONLY WORK ON A SINGLE TASK.
