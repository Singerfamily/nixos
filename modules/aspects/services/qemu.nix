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
        systemd.tmpfiles.rules = [
          "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware"
        ];
      };
  };
}
