# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Singer family NixOS configuration — three machines, two users, one flake. Built on the
[den framework](https://github.com/denful/den) layered over flake-parts + import-tree.

| Host            | Hardware                                  | User    | Profile |
| --------------- | ----------------------------------------- | ------- | ------- |
| `event-horizon` | AMD desktop, LUKS+Btrfs dual-disk         | eric | desktop |
| `clint-pc`      | Intel + NVIDIA hybrid, Sunshine streaming | clint | desktop |
| `thinkpad-p14s` | WSL (nixos-wsl), minimal                  | clint | wsl     |

## Commands

```bash
nix develop                        # devshell with all tooling (pre-commit, nh, etc.)
nix flake check --no-build         # validate all hosts evaluate — run before committing
nix run .#write-flake              # regenerate flake.nix after editing flake-file.inputs
nix fmt                            # treefmt: nixfmt + statix + deadnix + shfmt + prettier
sudo nixos-rebuild switch --flake .#$(hostname)
nh os switch .                     # alternative deploy (nh, from devshell)
scripts/setup-hooks.sh             # install git hooks once after cloning
scripts/deploy.sh <host> <flake-attr>  # remote install via nixos-anywhere
```

## Architecture

Every `.nix` file under `modules/` is auto-imported via `import-tree ./modules` (see `flake.nix`).
There is no central import list — adding a file is the same as registering it. New files must be
`git add`-ed; a pre-commit hook fails on untracked `modules/*.nix` files.

**`flake.nix` is generated** — header says `DO-NOT-EDIT`. Inputs are declared in two places:
`flake-file.inputs` keys scattered across modules (e.g. `modules/default.nix`, `modules/den.nix`),
then `nix run .#write-flake` regenerates `flake.nix`. Never hand-edit `flake.nix`.

**Aspects** are the core unit. An aspect is a self-contained module declaring `den.aspects.<name>`
with `nixos` and/or `homeManager` sub-modules — one concern per file (a service, toolchain,
desktop feature). Example: `modules/aspects/services/docker.nix`. Aspects are wired to hosts/users
through den's host-aspects and mutual-provider batteries.

Layout under `modules/`:

- `aspects/` — feature units (`services/`, etc.)
- `hosts/` — per-machine config; declares `den.hosts.<system>.<host>.users.<user>`
- `users/` — per-user config; declares `den.aspects.<user>` with den user batteries
- `profiles/` — `desktop` / `laptop` / `server` / `wsl` role bundles; `default.nix` sets `stateVersion`
- `packages/` — package/overlay modules
- `secrets/` — sops-nix module + encrypted `sops/*.yaml`
- `den.nix`, `disko.nix`, `formatter.nix`, `flake-file.nix`, `determinate.nix` — flake-level wiring

`stateVersion` is `26.05`, set once in `modules/profiles/default.nix` for both nixos and home-manager.

## Conventions

- One aspect = one file = one concern. Don't merge unrelated config into a single aspect.
- User-specific config (Plasma, shell aliases, `nh`) stays per-user — do not extract to shared
  modules even when identical across users.
- Tool-generated junk goes in the global gitignore via `programs.git.ignores` in the git aspect,
  not per-repo `.gitignore` files.
