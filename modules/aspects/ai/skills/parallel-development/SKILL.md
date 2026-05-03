---
name: parallel-development
description: >
  Patterns for running parallel Claude Code workstreams using git worktrees,
  sub-agents, and the operator pattern. Apply when working on large features
  that can be independently parallelized, or when task scope exceeds what a
  single session handles cleanly.
---

# Parallel Development

## Git Worktrees — Simultaneous Branch Work
Git worktrees let multiple Claude Code sessions work on separate branches of the same repository simultaneously, without conflicts. Each worktree is an isolated working directory with its own context.

Use when:
- Working on two features at once without checkout-switching
- Running a long-running refactor in parallel with bug fixes
- Experimenting on a branch without disrupting active development

Each session operates independently — no cross-contamination of context.

## Sub-Agents — Parallel Task Execution
Deploy sub-agents to handle parallel subtasks with isolated contexts. Sub-agents are effective when:
- A task has multiple independent components (e.g. write tests for module A while refactoring module B)
- You want to explore multiple approaches simultaneously and compare results
- Sequential execution would create a bottleneck

Each sub-agent gets a clean context scoped to its task — don't share cross-task context between them.

## Agent Tool — Spawning Sub-Agents
Use the `Agent` tool to spawn sub-agents. Key parameters:

- `prompt` — fully self-contained; the sub-agent starts with no shared context from the parent session. Include all necessary context, constraints, and file paths.
- `model` — specify the capability tier explicitly (see Cost Efficiency).
- `isolation: "worktree"` — automatically creates an isolated git worktree for the sub-agent. The worktree is cleaned up if the agent makes no changes. Use this instead of manually running `git worktree add` when the sub-agent will make file changes.

## Operator Pattern — Coordinated Multi-Agent Work
For large features, use a coordinating Claude instance as the **operator** and separate instances as **implementers**:
- The operator breaks the feature into independent, parallelizable units
- The operator assigns units to sub-agents in separate terminals
- The operator monitors progress and handles blockers
- Implementers do not share context with each other — only with the operator

The operator's job is coordination, not implementation. This mimics a technical lead managing a team.

## Reviewing Parallel Results — Required Before Completion
After parallel agents complete, their outputs must be reviewed before the task is considered done:
- Read each agent's result output
- Check for conflicts between agents (e.g. two agents editing the same file differently)
- Integrate changes manually if needed — agents work in isolation and cannot resolve conflicts with each other

Never report parallel work as complete without reviewing each agent's result.

## When NOT to Parallelize
Parallel sessions are not always better. Avoid them when:
- Tasks share state or have sequencing dependencies
- The overhead of coordination exceeds the time saved
- You'd spend more time merging outputs than you'd save on parallelization

Sequential sessions with clean `/clear` between tasks often outperform poorly-scoped parallel ones.

## Cost Efficiency — Right Model, Right Task
In `Agent` tool calls, specify the model explicitly using the `model` parameter:
- `model: "haiku"` — boilerplate, formatting, well-specified search tasks, summarization
- `model: "sonnet"` — standard feature development, most implementation tasks
- `model: "opus"` — architectural decisions, complex debugging, plan-mode reasoning

Specifying no `model` uses the session default — be deliberate when spawning sub-agents. Routing boilerplate to the smallest capable model and reserving the largest for reasoning-intensive tasks reduces cost without sacrificing output quality.
