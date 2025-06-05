{ ... }:
{
  nix = {
    settings = {
      trusted-users = [
        "root"
        "@wheel"
        "@builders"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
        "pipe-operators"
      ];
      warn-dirty = false;
      system-features = [
        "kvm"
        "big-parallel"
        "nixos-test"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
}
