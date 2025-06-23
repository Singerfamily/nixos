{
  lib,
  pkgs,
  config,
  ...
}:
{
  snowfall = {
    boot = {
      type = "uefi"; # Use UEFI bootloader
      # encrypted = true; # Enable LUKS2 encryption
      # quiet = true; # Enable Plymouth and reduce TTY verbosity
    };

    docker = {
      enable = true;
      # implementation = "both";
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
  };

  programs = {
    # kdeconnect.enable = true;
    # vscode.enable = true;
  };

  services = {
    vscode-server.enable = true;
  };

  environment = {
    variables = {
      NIXOS_OZONE_WL = "1";
    };
    systemPackages = with pkgs; [
      # nixd
      # binutils
      # htop
      # nixfmt-rfc-style
      # tpm2-tss
      # nvtopPackages.full
      # usbutils
      # ethtool
      # vscode

      # deno
    ];
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    # settings = {
    #   PermitRootLogin = "no";
    #   PasswordAuthentication = "no";
    #   PubkeyAuthentication = "yes";
    #   ChallengeResponseAuthentication = "no";
    #   UsePAM = "yes";
    #   X11Forwarding = "yes";
    #   AllowAgentForwarding = "yes";
    #   AllowTcpForwarding = "yes";
    #   PrintMotd = "no";
    #   PrintLastLog = "yes";
    # };
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "usbhid" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/8936eed1-ba38-47d9-aa87-819a2ac1bb9d";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/013A-5554";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];


#   networking.hostId = "edc49e33";

  system.stateVersion = "24.11";
}
