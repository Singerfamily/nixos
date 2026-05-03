---
name: advanced-workflows
description: >
  Advanced Claude Code patterns for automation, debugging, error recovery, and
  output verification. Apply for recurring tasks, UI/layout verification,
  error correction, and live documentation access. Covers /loop, hooks,
  screenshots, Context7, safe autonomy, and API vs MCP tradeoffs.
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

## Notifications — Stay Informed Without Watching
Set up completion hooks to receive alerts when long-running tasks finish. If a task takes minutes, don't poll — configure a hook that notifies you and return when it's done.

## Screenshots — Visual Verification
Use screenshots to verify UI layouts, catch rendering errors, and confirm that visual output matches intent. Don't rely solely on code review for layout-dependent work — render it and look at it.

Screenshot verification is especially valuable for:
- Responsive design correctness
- Component spacing and alignment
- Cross-browser rendering validation

## Error Recovery — Exit Early, Re-Prompt
When Claude deviates from the intended path:
1. Stop immediately — don't let bad output compound
2. Use `/re` to roll back to a previous conversation point if possible
3. Re-prompt with corrected or more constrained instructions

Continuing from a flawed output is more expensive than restarting with a corrected prompt.

## Challenge and Iterate
Don't accept the first output as final for complex work. After receiving output, push for improvement:
- Ask what the output gets wrong
- Ask for a simpler version (`/simplify`)
- Ask what a code reviewer would flag

Iteration toward better output is part of the workflow, not a sign that the first prompt failed.

## Context7 MCP — Live Documentation
Use the Context7 MCP server to give Claude live access to up-to-date technical documentation. This prevents Claude from reasoning from stale training data on rapidly-evolving APIs, frameworks, or tools.

Add Context7 to your MCP config when working with libraries or services that update frequently.

## API Endpoints vs MCP Servers
For well-defined integrations, calling API endpoints directly is often more token-efficient than routing through an MCP server:
- Direct API calls reduce context overhead from MCP scaffolding
- Useful when the MCP server adds abstraction but not value for your specific task
- Reserve MCP servers for integrations that genuinely benefit from the protocol layer

## Chrome DevTools Integration
Claude can interact with running web apps through Chrome DevTools — inspect DOM state, read console errors, and validate runtime behavior directly. Use for:
- Debugging rendering issues in live code
- Verifying network request payloads
- Testing interactions that are hard to express as unit tests

## Safe Autonomy — Customize Permissions
Set fine-grained permissions to let Claude operate autonomously on safe operations while requiring confirmation for risky ones:
- Allow: read, lint, format, test execution
- Require confirmation: destructive operations, external API calls, file deletions

Constrained autonomy is more useful than full autonomy — it removes friction from safe tasks without introducing risk on dangerous ones.

## VPS Hosting — Persistent Remote Sessions
Host Claude Code on a virtual private server for sessions that outlast your local machine's uptime. Enables:
- Remote management from any device (phone, tablet, browser)
- Uninterrupted long-running tasks
- Sessions that aren't killed by sleep/network interruption

Pair with a remote control setup to manage sessions from anywhere.