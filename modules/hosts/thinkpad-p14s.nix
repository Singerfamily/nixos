{ den, inputs, ... }:
{
  den.hosts.x86_64-linux.thinkpad-p14s.users.csinger = { };

  den.aspects.thinkpad-p14s = {
    includes = with den.aspects;[
      sops
      determinate
    ];

    nixos =
      { lib, ... }:
      {
        imports = [ inputs.nixos-wsl.nixosModules.default ];
        wsl.enable = true;
        fileSystems."/".device = "/dev/noroot";
        boot.loader.grub.enable = false;
        boot.loader.systemd-boot.enable = lib.mkForce false;
      };
  };

  flake-file.inputs.nixos-wsl = {
    url = "github:nix-community/nixos-wsl";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-compat.follows = "";
  };
}
