{ config, lib, username, pkgs, ... }: let
  cfg = config.services.qemu;
in {

  imports = [
    ./podman.nix
    ./docker.nix
  ];

  options.services.qemu = {
    enable = lib.mkEnableOption "Enable Virtual Machine support";
  };

  config = lib.mkIf cfg.enable {
    boot = {
      kernelModules = ["kvm-intel" "kvm-amd" "vfio-pci"];
      kernelParams = [ "intel_iommu=on" "iommu=pt"];
    };

    # Enable dconf (System Management Tool)
    programs = {
      dconf.enable = true;
      virt-manager.enable = true;
    };

    # Add user to libvirtd group
    users.users."${username}".extraGroups = [ "libvirtd" ];

    # Install necessary packages
    environment.systemPackages = with pkgs; [
      qemu
      virt-manager
      virt-viewer
      spice spice-gtk
      spice-protocol
      win-virtio
      win-spice
    ];

    # Manage the virtualisation services
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true;
          ovmf.enable = true;
          ovmf.packages = [ pkgs.OVMFFull.fd ];
        };
      };
      spiceUSBRedirection.enable = true;
    };
    services.spice-vdagentd.enable = true;
  };
}