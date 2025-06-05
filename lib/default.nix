{ snowfallorg, ... }:
{
  # Common Nix settings.
  #
  # Lives here because it's shared between NixOS and Home-manager.
  nix.settings = {
    allowed-users = [
      "@builders"
    ] ++ snowfallorg.users.allowed-users;
    trusted-users = [
      "@builders"
    ];

    substituters = [
      "https://cache.nixos.org"
      "https://cuda-maintainers.cachix.org"
      "https://hyprland.cachix.org"
      "https://wezterm.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
    ];

    warn-dirty = false;
    experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
  };
}
