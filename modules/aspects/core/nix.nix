_:
{
  den.default = {
    nixos =
      _:
      {
        nix.settings = {
          trusted-users = [
            "@wheel"
          ];
          allowed-users = [
            "@wheel"
          ];
          experimental-features = [
            "nix-command"
            "flakes"
            "pipe-operators"
            "ca-derivations"
          ];
          system-features = [
            "kvm"
            "big-parallel"
            "nixos-test"
          ];
          warn-dirty = false;
          auto-optimise-store = true;
          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };
        nix.gc = {
          automatic = true;
          options = "--delete-older-than 14d";
        };
        nixpkgs.config.allowUnfree = true;
      };
    homeManager =
      _:
      {
        nixpkgs.config.allowUnfree = true;
      };
  };
}
