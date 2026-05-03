---
name: nix-agent
description: Use when a user wants to change NixOS packages, options, modules, or local configuration through the nix-agent and mcp-nixos MCP servers, especially when a generic brainstorming or planning workflow would be unnecessary overhead.
---

# Nix Agent

## Overview

Use this skill for straightforward NixOS execution tasks through `nix-agent` and `mcp-nixos`. Core principle: use `mcp-nixos` for discovery, use `nix-agent` for local mutation and activation, and do not detour into generic design workflows unless the user is explicitly asking for architecture.

## When to Use

- A user asks to install a package on NixOS.
- A user asks which option or module setting to use, then wants it applied.
- A user asks to patch local NixOS config through MCP tools.
- The host exposes both `nix-agent` and `mcp-nixos` and the task is operational, not architectural.
- A generic brainstorming or planning skill would slow down an otherwise direct NixOS MCP workflow.

Do not use this skill for imperative package installs, writing secret payloads, or broad architecture/design requests.

## Priority Rule

For direct NixOS MCP execution tasks, this skill takes precedence over generic brainstorming or planning workflows.

If the user says things like:

- `install X on NixOS`
- `enable this option`
- `patch my NixOS config`
- `use mcp-nixos and nix-agent together`

then execute the `mcp-nixos` + `nix-agent` workflow directly.

Do **not** start a generic brainstorming flow first unless the user is asking for architecture, design trade-offs, or multi-approach planning.

## Quick Reference

- `mcp-nixos` for package and option discovery
- `plan_change(goal)` before mutation
- `apply_patch_set(patch_set)`
- `run_formatters(changed_files)`
- `classify_change(changed_files)`
- `apply_change(intent, changed_files, flake_uri)` if allowed

## Required Workflow

1. If the request needs package or option discovery, query `mcp-nixos` first.
2. Call `plan_change(goal)`.
3. If `requires_mcp_nixos=true`, stop local mutation and use `mcp-nixos` before continuing.
4. Build a `PatchSet` and call `apply_patch_set(patch_set)`.
   - **New files:** If `apply_patch_set` creates a new `.nix` file, run `git add <file>` before continuing. Nix flakes only evaluate git-tracked files — untracked files are silently ignored by `nix flake check`, producing false-clean results.
5. If `apply_patch_set()` returns `status="approval_required"`, stop and report that approval is needed.
6. Run `run_formatters(changed_files)`. The Nix formatter is `alejandra` (or `nixfmt-rfc-style` if the project uses it — check existing formatted files to determine which applies).
7. Run `classify_change(changed_files)`.
8. If `approval_required` is `true`, stop and report the reason.
9. Only then call `apply_change(intent, changed_files, flake_uri)`.
10. After `apply_change` completes, run `nix flake check --no-build` to confirm the configuration evaluates cleanly. If it fails, diagnose before reporting completion.

## Flake Inputs — Do Not Edit flake.nix Directly

`flake.nix` is auto-generated and will be overwritten. To add a new flake input:
1. Add the input to `flake-file.inputs` in `modules/dendritic.nix`.
2. Run `nix run .#write-flake` to regenerate `flake.nix`.

Never edit `flake.nix` by hand.

## Aspect Names — Derived from Filename

Aspect names come from the `.nix` **filename**, not the directory path. The `import-tree` loader uses the filename (without extension) as the aspect identifier. Moving a file to a different directory does not rename the aspect — renaming the file does.

Example: `modules/aspects/apps/discord.nix` → aspect name is `discord`, not `apps.discord`.

## Common Mistakes

- Starting a generic brainstorming/design workflow for a simple package install.
- Skipping `mcp-nixos` and guessing package names or option paths.
- Skipping `plan_change()`.
- Calling `apply_change()` right after patching without `run_formatters()`.
- Ignoring `approval_required`.
- Assuming `nix-agent` should do package discovery itself.
- Writing secret material through patches.
- Editing `flake.nix` directly instead of modifying `flake-file.inputs` in `dendritic.nix` and running `nix run .#write-flake`.
- Creating a new `.nix` file without `git add` before `nix flake check`.

## Red Flags

- `I should brainstorm first`
- `I need a design before installing this package`
- `I should explore the whole repo before calling the MCPs`
- `I can probably guess the NixOS option without mcp-nixos`

All of these mean: return to the `mcp-nixos` + `nix-agent` workflow.

## Example

User asks: `Use mcp-nixos and nix-agent together to install floorp on my NixOS system.`

1. Query `mcp-nixos` for the correct Floorp package attribute.
2. Call `plan_change("install floorp on NixOS")`.
3. Patch the relevant NixOS file with `apply_patch_set(...)`.
4. If the patched file is new, run `git add <file>`.
5. Run `run_formatters(changed_files)`.
6. Run `classify_change(changed_files)`.
7. If allowed, call `apply_change("install floorp", changed_files, flake_uri)`.
8. Run `nix flake check --no-build` to verify clean evaluation.
9. Report the changed file and each tool result.
