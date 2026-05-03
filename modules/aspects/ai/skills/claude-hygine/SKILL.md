---
name: claude-md-hygiene
description: >
  Rules for creating, maintaining, and evolving CLAUDE.md files in Claude Code
  projects. Apply when initializing a project, modifying project conventions,
  or working in a monorepo. CLAUDE.md is the highest return-on-effort setup
  task in any Claude Code project — keep it accurate, focused, and versioned.
---

# CLAUDE.md Hygiene

## Initialize Every Project
Run `/init` at the start of a new project to generate a `CLAUDE.md` file. This file acts as the project blueprint: architecture overview, naming conventions, key constraints, and patterns Claude should follow throughout the project.

A project without `CLAUDE.md` causes Claude to rediscover conventions through trial and error on every session.

## What Belongs in CLAUDE.md
Include **only** conventions that differ from sensible defaults — the things Claude would get wrong without being told:
- Project-specific patterns (e.g. "all DB queries go through the repository layer")
- Established error classes and how to use them
- Naming conventions for this codebase
- Architecture constraints (e.g. "no new dependencies without discussion")
- File structure rules

Do **not** include: generic best practices that apply to every project, obvious rules, or anything Claude already follows by default.

## Keep It Short and Focused
More content ≠ better output. A bloated `CLAUDE.md` consumes context and dilutes the most important rules. If a rule isn't specific to this codebase, cut it. The file should be scannable, not exhaustive.

## @filename — On-Demand File Imports
`CLAUDE.md` supports `@filename` syntax to import external files at read time. Claude Code resolves these and injects the referenced file's content.

Use this instead of inlining large reference material:
```
@docs/api-schema.md
@docs/db-patterns.md
```

Prefer `@filename` over prose links like `"see ./docs/api-schema.md"` — the former actually loads the content; the latter is passive and easy to ignore.

## Refresh Regularly
Update `CLAUDE.md` as the project evolves. Use the `/init` refresh to streamline and prune stale context. An outdated `CLAUDE.md` is worse than no file — it sends Claude down abandoned patterns.

## Version-Control CLAUDE.md
Commit `CLAUDE.md` changes alongside the code changes that motivated them. This preserves the reasoning behind rules and lets future collaborators (or future Claude sessions) understand why constraints exist.

## Machine-Local Settings
Use `.claude/settings.local.json` for settings that must not be committed: API keys, local binary paths, per-machine permissions, or personal workflow preferences. It is gitignored by default.

Use `.claude/settings.json` (committed) for team-shared permissions and project-level defaults.

## Monorepo: Use Directory-Level Files
Claude Code supports both root-level and subdirectory-level `CLAUDE.md` files:
- Root `CLAUDE.md`: global conventions for the whole repo
- `packages/frontend/CLAUDE.md`: frontend-specific rules
- `packages/backend/CLAUDE.md`: backend-specific rules

Claude Code loads `CLAUDE.md` from the repo root **and** from parent directories of the currently-open file. Subdirectory files are **additive** — they extend rather than replace the root file. Design them as narrowly scoped extensions, not self-contained replacements.
