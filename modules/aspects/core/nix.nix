{ den, ... }:
{
  # Smart nix defaults - applied to all hosts via den.default
  den.default = {
    nixos = { lib, ... }: {
      nix.settings = {
        trusted-users = lib.mkDefault [ "root" "@wheel" "@builders" ];
        allowed-users = lib.mkDefault [ "root" "@wheel" "@builders" ];
        experimental-features = lib.mkDefault [
          "nix-command"
          "flakes"
          "pipe-operators"
          "ca-derivations"
        ];
        system-features = lib.mkDefault [ "kvm" "big-parallel" "nixos-test" ];
        warn-dirty = lib.mkDefault false;
        auto-optimise-store = lib.mkDefault true;
        substituters = lib.mkDefault [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = lib.mkDefault [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
      nix.gc = {
        automatic = lib.mkDefault true;
        options = lib.mkDefault "--delete-older-than 14d";
      };
      nixpkgs.config.allowUnfree = lib.mkDefault true;
    };
    homeManager = { lib, ... }: {
      nixpkgs.config.allowUnfree = lib.mkDefault true;
    };
  };
}
