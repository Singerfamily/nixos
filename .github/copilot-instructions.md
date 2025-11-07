# copilot-instructions.md

## MANDATORY RULES

**DO NOT MAKE ANY CHANGES without googling first. Every change has to be confirmed that it's actually correct.**

Before making any Nix configuration changes, you MUST search:
- **NixOS options**: https://search.nixos.org/options?channel=25.05&from=0&size=50&sort=relevance&type=packages&query=[your-search]
- **Home Manager options**: https://home-manager-options.extranix.com/?release=release-25.05&query=[your-search]
- **NixOS Wiki**: For additional context and examples

If you cannot find the information needed, tell the user to google for you and paste the results.

## Repository Overview

This is a NixOS configuration repository using flakes and the Snowfall Lib framework.

## Common Development Commands

### System Rebuilding
- `nh os switch` - Rebuild and switch to new NixOS configuration
- `nh os boot` - Rebuild and set as boot configuration  
- `nh os test` - Test configuration without switching

### Code Formatting
- `nix fmt` - Format all Nix files using nixfmt-rfc-style

## Architecture

### Module System
The repository uses Snowfall Lib with a custom namespace. All modules are prefixed with `custom.`:
- `modules/nixos/` - System-level NixOS modules
- `modules/home/` - Home-manager modules  
- `systems/<arch>/<hostname>` - Host-specific configurations (workstation, vm)
- `homes/<arch>/<user>@<hostname>` - User@host specific home configurations

### Secret Management
Uses SOPS with age encryption:
- Secrets are in `secrets/` directory
- Configuration in `.sops.yaml`
- Access secrets in Nix with `config.sops.secrets.<name>`

## Important Notes

1. **All custom modules use the `snowfall` namespace** - e.g., `snowfall.programs.neovim`
2. **Test changes with `nh os test`** before switching
