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

## Operator Pattern — Coordinated Multi-Agent Work
For large features, use a coordinating Claude instance as the **operator** and separate instances as **implementers**:
- The operator breaks the feature into independent, parallelizable units
- The operator assigns units to sub-agents in separate terminals
- The operator monitors progress and handles blockers
- Implementers do not share context with each other — only with the operator

The operator's job is coordination, not implementation. This mimics a technical lead managing a team.

## When NOT to Parallelize
Parallel sessions are not always better. Avoid them when:
- Tasks share state or have sequencing dependencies
- The overhead of coordination exceeds the time saved
- You'd spend more time merging outputs than you'd save on parallelization

Sequential sessions with clean `/clear` between tasks often outperform poorly-scoped parallel ones.

## Cost Efficiency — Right Model, Right Task
Match model capability to task complexity:
- **Haiku** — simple transformations, boilerplate, formatting, summarization
- **Sonnet** — standard feature development, moderate complexity
- **Opus** — architectural decisions, complex debugging, plan-mode reasoning

Using Opus for every task is unnecessary and expensive. Using Haiku for architecture decisions produces poor results. Be deliberate.