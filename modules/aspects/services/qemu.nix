{ den, ... }:
{
  den.aspects.qemu = {
    nixos =
      { lib, pkgs, ... }:
      {
        virtualisation.libvirtd.enable = lib.mkDefault true;
        environment.systemPackages = with pkgs; [
          qemu
          virt-manager
        ];
      };
  };
}
