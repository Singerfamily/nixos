---
name: planning-and-prompting
description: >
  Rules for how Claude Code should approach planning, receiving tasks, and
  prompting itself toward higher-quality outputs. Apply before writing any
  code, and during self-review. Covers plan-first workflow, constraint
  front-loading, self-critique, plan mode with ExitPlanMode, TodoWrite,
  and the GSD framework.
---

# Planning and Prompting

## Plan Before Code
For any non-trivial task, produce a written plan **before** writing code:
- Which files will change
- What approach will be taken
- What edge cases are accounted for

Present the plan for review and correction. Catching misunderstandings in the plan phase is orders of magnitude cheaper than undoing bad code.

## TodoWrite — Decompose Plans into Trackable Tasks
After producing a plan, use `TodoWrite` to break it into a tracked task list:
- Mark each task complete immediately when done — do not batch completions
- The list persists across `/compact` calls — survives context summarization
- Use for any plan with three or more sequential steps

A visible task list makes progress recoverable without relying on conversation history.

## Front-Load Constraints, Not Just Goals
Weak prompt: `"Add authentication."`  
Strong prompt: `"Add authentication using the existing JWT pattern in auth.ts, no new dependencies, following the error handling pattern already in use."`

Include **what not to do**, which patterns to follow, and which existing conventions to respect. Constraints given upfront beat corrections given after the fact every time.

## Include Failure Modes
Describe the unhappy path, not just the happy path:
- What should happen on invalid input?
- Which existing error classes should be used?
- What should NOT be thrown or returned?

Code that accounts for failure modes in the prompt is production-ready code; code that doesn't is prototype code that gets refactored.

## Self-Critique After Output
After producing output, ask: *"What's wrong with this? What edge cases does it miss? What would a senior engineer flag in code review?"*

This surfaces real problems. "Does this look right?" almost always returns a yes. Specific critique prompts do not.

## Plan Mode — Architecture and Complex Design
Use `/plan` to enter plan mode for architecture decisions and complex multi-step features. In plan mode:
- Use **read-only tools only** — do not begin implementation
- Build a complete written plan: which files change, what approach, what edge cases
- Call `ExitPlanMode` after presenting the plan to hand off to the user for approval
- Do not begin implementation until the user approves the plan

Plan mode exists to catch misunderstandings before any code is written. A corrected plan is worth more than code that has to be undone. Within plan mode, prefer the most capable available model — plan quality matters more than generation speed.

## Ask Clarifying Questions Before Starting
Before beginning complex work, surface ambiguities proactively:
- What constraints apply (dependencies, patterns to follow, things to avoid)?
- Which existing files or patterns should be treated as canonical?
- What is the definition of done — what does success look like?

Ask these before writing the first line of code. Silent assumptions made at the start of a task compound into rework at the end.

## GSD Framework for Complex Work
Break complex multi-step tasks into three clean phases, each with isolated context:
1. **Gather** — collect context, read relevant files, understand the landscape
2. **Specify** — define the exact approach with constraints confirmed
3. **Do** — execute against the specified plan

Earlier exploration should not pollute later execution. Phase separation keeps outputs clean.

## /simplify — Counter Over-Engineering
When output has too much ceremony for the task, use `/simplify` to request the minimum working version. Useful for prototypes and for resetting when Claude adds abstractions that weren't asked for.
