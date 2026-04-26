# nixos

Singer family NixOS configuration. Three machines, two users, managed as a single flake using the
[den framework](https://github.com/vic/den) with flake-parts and import-tree.

## Hosts

| Hostname | Hardware | Primary user |
|---|---|---|
| `event-horizon` | AMD desktop, LUKS+Btrfs dual-disk | esinger |
| `clint-pc` | Intel + NVIDIA hybrid GPU, Sunshine streaming | csinger |
| `thinkpad-p14s` | WSL (nixos-wsl), minimal config | csinger |

## Quick start

```bash
nix develop              # enter devshell with all tools
scripts/setup-hooks.sh   # install git pre-commit hooks (run once after cloning)
nix flake check --no-build  # validate all hosts evaluate cleanly
```

Deploy to the current machine:
```bash
sudo nixos-rebuild switch --flake .#$(hostname)
# or use nh (available in devshell):
nh os switch .
```

## Architecture

Configuration is organised into **aspects** — self-contained units in `modules/aspects/` that each
handle one concern (a service, a language toolchain, a desktop feature). Every `.nix` file under
`modules/` is auto-imported. See [CLAUDE.md](CLAUDE.md) for the full architecture reference.

## Adding a new aspect

```bash
cp templates/ASPECT_TEMPLATE.nix modules/aspects/<domain>/<feature>.nix
# edit the file, then:
git add modules/aspects/<domain>/<feature>.nix
nix flake check --no-build
```

Or use the scaffolding script from inside the devshell:
```bash
new-aspect <domain> <feature>
```

## Off-limits

`secrets/**`, `.sops.yaml`, and key files must never be read, written, decrypted, or reformatted.
See the [Off-Limits Files](CLAUDE.md#off-limits-files) section in CLAUDE.md.
