{ den, ... }:
{
  # WSL role bundle. Intentionally empty — WSL-specific config lives in the
  # host aspect (modules/hosts/thinkpad-p14s/default.nix), and Determinate is
  # deliberately excluded here since nixos-wsl manages Nix on WSL.
  den.aspects.profile-wsl = {
    includes = with den.aspects; [
    ];
  };
}
