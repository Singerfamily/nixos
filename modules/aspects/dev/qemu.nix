_:
{
  den.aspects.qemu = {
    nixos =
      { pkgs, ... }:
      {
        # Users needing libvirt access must add "libvirtd" to their extraGroups
        virtualisation.libvirtd = {
          enable = true;
          qemu.runAsRoot = false;
          qemu.swtpm.enable = true;
        };
        programs.virt-manager.enable = true;
        environment.systemPackages = [
          pkgs.spice-gtk
          pkgs.virtiofsd
        ];
      };
  };
}
