{ vix, ... }:
{
  flake-file.inputs.nixos-wsl = {
    url = "github:nix-community/nixos-wsl";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-compat.follows = "";
  };

  den.aspects.thinkpad-p14s = {
    includes = [ ];
    nixos = {
      fileSystems."/".device = "/dev/noroot";
      boot.loader.grub.enable = false;
    };
  };
}