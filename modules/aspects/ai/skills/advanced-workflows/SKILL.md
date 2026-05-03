---
name: advanced-workflows
description: >
  Advanced Claude Code patterns for automation, debugging, error recovery, and
  output verification. Apply for recurring tasks, UI/layout verification,
  error correction, and live documentation access. Covers /loop, hooks,
  screenshots, browser tools, safe autonomy, and API vs MCP tradeoffs.
---

# Advanced Workflows

## /loop — Recurring Automated Tasks
The `/loop` command runs a task on a recurring schedule for up to 72 hours without manual intervention. Use for:
- Periodic health checks or monitoring
- Automated test runs on a schedule
- Background tasks that need to recur while you work elsewhere

Scope the task clearly before enabling a loop — unconstrained loops on ambiguous tasks produce unpredictable output.

## Hooks — Event-Driven Automation
Configure hooks to trigger on Claude Code lifecycle events:
- **PreToolUse** — run linting or validation before edits are made
- **PostToolUse** — run tests or notifications after a tool call completes
- **SessionStart** — load git status or environment context automatically
- **PreCompact** — backup transcript before compaction

Hooks remove the need to manually trigger recurring verification steps. Automate what repeats.

To configure hooks, use the `update-config` skill rather than editing `settings.json` directly — it validates hook shape and places it in the correct settings scope.

## Notifications — Stay Informed Without Watching
Set up completion hooks to receive alerts when long-running tasks finish. If a task takes minutes, don't poll — configure a hook that notifies you and return when it's done.

## Browser Tools — Use When Available
Check the active tool list at the start of any task involving web content, UI, or network requests.

If a browser MCP (Puppeteer, Playwright) is available:
- Prefer browser MCP tools over bash-based alternatives for screenshots, DOM inspection, and network monitoring
- Use it to open the dev server URL and render the actual UI rather than reasoning from source
- Use it for web research that requires JavaScript execution or login-gated content

If no browser MCP is available:
- Screenshots: use bash (`gnome-screenshot`, `import -window root screenshot.png`, `scrot`)
- Network inspection: use `curl`, `httpie`, or dev-server logs
- Web research: use WebSearch/WebFetch tools if available; otherwise reason from training data and flag the limitation

Do not assume a browser MCP is available — verify from the tool list before attempting to call it.

## Screenshots — Visual Verification
Use screenshots to verify UI layouts, catch rendering errors, and confirm that visual output matches intent. Don't rely solely on code review for layout-dependent work — render it and look at it.

How to take screenshots:
- If a browser MCP (Puppeteer, Playwright) is available, use its screenshot tool directly.
- Otherwise, open the dev server URL and use a bash command (`gnome-screenshot`, `import -window root screenshot.png`, `scrot`) to capture the screen.
- Prefer rendering the actual component over inspecting source — visual bugs are not always visible in code.

Screenshot verification is especially valuable for:
- Responsive design correctness
- Component spacing and alignment
- Cross-browser rendering validation

## Error Recovery — Exit Early, Re-Prompt
When Claude deviates from the intended path:
1. Stop immediately — don't let bad output compound
2. Use `/clear` to start a clean session if prior context is polluted
3. Re-prompt with corrected or more constrained instructions

Continuing from a flawed output is more expensive than restarting with a corrected prompt.

## Challenge and Iterate
Don't accept the first output as final for complex work. After receiving output, push for improvement:
- Ask what the output gets wrong
- Ask for a simpler version (`/simplify`)
- Ask what a code reviewer would flag

Iteration toward better output is part of the workflow, not a sign that the first prompt failed.

## Context7 MCP — Live Documentation
When a Context7 MCP is visible in the tool list, use it to resolve documentation queries before reasoning from training data. Training data goes stale; Context7 returns current documentation.

Trigger it when:
- Working with a library or framework that updates frequently
- Training-data answers feel uncertain or produce deprecation warnings
- The task involves a version-specific API

## API Endpoints vs MCP Servers
For well-defined integrations, calling API endpoints directly is often more token-efficient than routing through an MCP server:
- Direct API calls reduce context overhead from MCP scaffolding
- Useful when the MCP server adds abstraction but not value for your specific task
- Reserve MCP servers for integrations that genuinely benefit from the protocol layer

## Chrome DevTools Integration
If a browser control MCP (Puppeteer or Playwright) is configured, use it to interact with running web apps — inspect DOM state, read console errors, and validate runtime behavior. Use for:
- Debugging rendering issues in live code
- Verifying network request payloads
- Testing interactions that are hard to express as unit tests

If no browser MCP is available, use bash-based tooling (`curl`, `httpie`) for network inspection and rely on dev-server logs for runtime errors.

## Safe Autonomy — Customize Permissions
Set fine-grained permissions to let Claude operate autonomously on safe operations while requiring confirmation for risky ones:
- Allow: read, lint, format, test execution
- Require confirmation: destructive operations, external API calls, file deletions

Constrained autonomy is more useful than full autonomy — it removes friction from safe tasks without introducing risk on dangerous ones.
