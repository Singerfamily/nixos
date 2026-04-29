_:
{
  den.aspects.qemu = {
    nixos =
      { pkgs, ... }:
      {
        virtualisation.libvirtd.enable = true;
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
