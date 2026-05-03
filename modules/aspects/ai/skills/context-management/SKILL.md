---
name: context-management
description: >
  Rules for managing Claude Code's context window efficiently. Apply these
  guidelines proactively throughout every session — not just when degradation
  is visible. Covers /compact, /clear, TodoWrite, ultrathink, and MCP hygiene.
---

# Context Management

## Core Principle
A bloated context produces worse code. A collapsed context loses work. Stay in the productive middle by managing context **proactively**, not reactively.

## /compact — Compress Early
- Run `/compact` at natural breakpoints (feature complete, module switch) before the context feels full.
- Target: compact when context usage hits ~60–70%, not when output quality degrades.
- `/compact` replaces conversation history with a structured summary — it preserves intent but frees window space.

## /compact vs /clear — Choose Deliberately
`/compact` is for **continuing the same task** with less context overhead — it preserves task intent while freeing window space.

Use `/clear` (or start a new session) when:
- The next task is unrelated to the current one
- Context rot is severe (see below)
- You want a clean baseline without summary artifacts

`/compact` is not a substitute for task separation. The precision lost in compaction accumulates — if the task changes, start fresh.

## /clear — Clean Slate Between Tasks
Use `/clear` when switching to a completely unrelated task or starting fresh work. Unrelated task context bleeds into and degrades output — separate sessions are free, bad outputs are not.

## TodoWrite — Track Multi-Step Progress Within a Session
Use the `TodoWrite` tool to decompose complex tasks into a tracked task list:
- The list persists across `/compact` calls — survives summarization
- Mark items complete immediately as each finishes — do not batch completions
- Use for any task with three or more sequential steps

A visible task list makes progress recoverable after compaction without relying on conversation history.

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

## MCP Server Hygiene
- Every enabled MCP server adds to context overhead on every request.
- Disable MCP servers that aren't actively needed for the current task.
- Lean MCP config = more context budget for actual code.

## Monitor Context Window Actively
- Watch the context usage indicator in the UI — don't wait for quality to drop.
- At ~70% full: `/compact` or end the session and start fresh for the next task.
