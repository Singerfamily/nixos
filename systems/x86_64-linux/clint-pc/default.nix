{
  lib,
  pkgs,
  config,
  ...
}:
{
  snowfallorg.users = {
    "csinger".admin = true;
  };

  snowfall = {
    boot = {
      type = "uefi";
    };

    docker = {
      enable = true;
    };

    flatpak.enable = true;

    hardware = {
      bluetooth.enable = true;
      gpu = {
        intel = {
          enable = true;
          busID = "PCI:0:2:0";
        };
        nvidia = {
          enable = true;
          busID = "PCI:1:0:0";
        };
      };
    };

    qemu.enable = true;

    net.ssh = {
      enable = true;
      server = true; # Allow SSH'ing into this machine
    };

    # FIXME: Snowfall Lib isn't auto-discovering the dotnetCerts module
    # security.dotnetCerts = {
    #   enable = true;
    #   users = [ "csinger" ];
    # };
  };

  # environment =
  #   let
  #     dotnet = (with pkgs.dotnetCorePackages; combinePackages [ dotnet_9.sdk ]);
  #   in
  #   {
  #     sessionVariables = {
  #       DOTNET_PATH = "${dotnet}/bin/dotnet";
  #       DOTNET_ROOT = "${dotnet}/share/dotnet";
  #     };

  #     systemPackages = with pkgs; [
  #       dotnet
  #     ];
  #   };

  # fileSystems."/mnt/nfs/clint" = {
  #   device = "192.168.1.3:/mnt/stuff/clint";
  #   fsType = "nfs";
  # };

  # RDP server for remote desktop access
  services.xrdp = {
    enable = true;
    defaultWindowManager = "startplasma-x11";
    openFirewall = true;
  };

  # For mount.cifs, required unless domain name resolution is not needed.
  # Trust ASP.NET Core development certificate
  security.pki.certificateFiles = [
    ./aspnetcore-dev-cert.crt
  ];

  environment.systemPackages = with pkgs; [
    cifs-utils
    jq
    google-chrome
    firefox
    microsoft-edge
  ];

  xdg.mime.defaultApplications = {
    "text/html" = "microsoft-edge.desktop";
    "x-scheme-handler/http" = "microsoft-edge.desktop";
    "x-scheme-handler/https" = "microsoft-edge.desktop";
    "x-scheme-handler/about" = "microsoft-edge.desktop";
    "x-scheme-handler/unknown" = "microsoft-edge.desktop";
  };
  fileSystems."/mnt/backup" = {
    device = "//192.168.1.3/clint";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      in
      [ "${automount_opts},credentials=/etc/nixos/.secret-smb" ];
  };

  # DANGER - Do not Modify Below!
  boot.initrd.availableKernelModules = [
    "vmd"
    "xhci_pci"
    "ahci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.extraModprobeConfig = "options kvm-intel nested=1";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5ce2ae63-604b-4e22-9923-4dc1f479ade6";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1454-A232";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/9e72bc8a-7a48-4c4d-b180-6cd63a6aa1bd"; }
  ];

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/f54eca10-f82e-4531-a24f-af500a7e45bf";
    fsType = "ext4";
    # options = [ "subvol=log" "compress=zstd" "noatime" ];
    # neededForBoot = false;
  };

  environment = {
    variables = {
      LIBVIRT_DEFAULT_URI = "qemu:///system";
    };
  };

  system.stateVersion = "24.11";
}
