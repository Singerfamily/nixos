---
name: context-management
description: >
  Rules for managing Claude Code's context window efficiently. Apply these
  guidelines proactively throughout every session — not just when degradation
  is visible. Covers /compact, /clear, ultrathink, effort levels, and MCP hygiene.
---

# Context Management

## Core Principle
A bloated context produces worse code. A collapsed context loses work. Stay in the productive middle by managing context **proactively**, not reactively.

## /compact — Compress Early
- Run `/compact` at natural breakpoints (feature complete, module switch) before the context feels full.
- Target: compact when context usage hits ~60–70%, not when output quality degrades.
- `/compact` replaces conversation history with a structured summary — it preserves intent but frees window space.

## /clear — Clean Slate Between Tasks
- Use `/clear` when switching to a completely unrelated task or starting fresh work.
- Unrelated task context bleeds into and degrades output — separate sessions are free, bad outputs are not.

## Context Rot — Recognize It Early
Symptoms of context rot:
- Claude repeats suggestions already dismissed
- Claude contradicts earlier decisions in the same session
- Solutions ignore constraints that were explicitly stated
  
Fix: `/compact` if context is salvageable; new session if rot is severe.

## ultrathink — Reserve for Hard Problems
- Typing `ultrathink` (no slash) in a prompt triggers extended reasoning with maximum token budget.
- Use for: architecture decisions, complex debugging, algorithm design.
- Do **not** use for: boilerplate, formatting, simple refactors — it wastes compute.

## Effort Levels — Set Explicitly
Claude Code has four effort levels: `low`, `medium`, `high`, `max`. State the desired level in your prompt when the default is likely wrong:
- `low` — formatting fixes, trivial renames
- `high`/`max` — novel algorithms, multi-file refactors, security-sensitive logic

## MCP Server Hygiene
- Every enabled MCP server adds to context overhead on every request.
- Disable MCP servers that aren't actively needed for the current task.
- Lean MCP config = more context budget for actual code.

## /btw — Add Context Without Breaking Flow
- `/btw <message>` injects a note or clarification mid-task without consuming a full conversation turn.
- Use it to steer Claude without interrupting ongoing work.

## Monitor Context Window Actively
- Watch the context usage indicator in the UI — don't wait for quality to drop.
- At ~70% full: `/compact` or end the session and start fresh for the next task.