# INFO: Core Nix library, accessible from anywhere in the flake.

{
  inputs,
  lib,
  ...
}:

rec {
  # A no-nixpkgs standard library for the nix language.
  # Mostly used for (de)serialization of stuff.
  nix-std = builtins.attrValues inputs.nix-std.lib;

  user = "esinger";

  # The name of the persistent volume, so I never mess it up.
  persist = "/persist";

  # SSH (and other?..) public keys, so I also never mess them up. Also,
  # should I make a new private key, this would make it much easier to
  # quickly update the public ones everywhere too.
  pubKeys = [
  ];

  # Common Nix settings.
  #
  # Lives here because it's shared between NixOS and Home-manager.
  nix.settings = {
    allowed-users = [
      "@builders"
      "${user}"
    ];
    trusted-users = [
      "@builders"
      "${user}"
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
