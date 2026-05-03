---
name: planning-and-prompting
description: >
  Rules for how Claude Code should approach planning, receiving tasks, and
  prompting itself toward higher-quality outputs. Apply before writing any
  code, and during self-review. Covers plan-first workflow, constraint
  front-loading, self-critique, and the GSD framework.
---

# Planning and Prompting

## Plan Before Code
For any non-trivial task, produce a written plan **before** writing code:
- Which files will change
- What approach will be taken
- What edge cases are accounted for

Present the plan for review and correction. Catching misunderstandings in the plan phase is orders of magnitude cheaper than undoing bad code.

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

## Use Plan Mode (Opus) for Architecture
For complex features where approach quality matters more than generation speed:
- Use Opus in plan mode to produce the architecture decision
- Hand off implementation to a faster model
- You get Opus-quality reasoning without paying Opus prices on every generated line

## Treat Claude Like a Junior Developer
Present problems to solve, not commands to execute. Ask clarifying questions to ensure task scope and intent are understood before proceeding. Collaboration produces better outcomes than blind execution.

## GSD Framework for Complex Work
Break complex multi-step tasks into three clean phases, each with isolated context:
1. **Gather** — collect context, read relevant files, understand the landscape
2. **Specify** — define the exact approach with constraints confirmed
3. **Do** — execute against the specified plan

Earlier exploration should not pollute later execution. Phase separation keeps outputs clean.

## /simplify — Counter Over-Engineering
When output has too much ceremony for the task, use `/simplify` to request the minimum working version. Useful for prototypes and for resetting when Claude adds abstractions that weren't asked for.

## Prompt Claude to Ask Clarifying Questions
Before beginning complex work, prompt Claude to surface ambiguities:
*"Before you start, ask me any clarifying questions you need to do this correctly."*

Align on intent before the first line of code is written.