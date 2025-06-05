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
  };

  # snowfall.hardware.adb.enable = true;

  services = {
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      autoNumlock = true;
    };
    desktopManager.plasma6.enable = true;
  };

  environment.systemPackages =
    with pkgs;
    [
      aha
      fwupd
      vulkan-tools
      wayland-utils
      pciutils
    ]
    ++ (with pkgs.kdePackages; [
      discover
      kaccounts-integration
      kaccounts-providers
      plasma-browser-integration
      plasma-disks
      kalk
      partitionmanager
      krdc
      (lib.mkIf config.services.hardware.bolt.enable plasma-thunderbolt)
    ]);

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

  disko.devices =
    let
      inherit (config.networking) hostName;
    in
    {
      disk = {
        main = {
          type = "disk";
          device = "/dev/nvme0n1";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "${lib.toUpper hostName}_LUKS";
                  # disable settings.keyFile if you want to use interactive password entry
                  #passwordFile = "/tmp/secret.key"; # Interactive
                  settings = {
                    allowDiscards = true;
                    # keyFile = "/tmp/secret.key";
                  };
                  # additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
                  content = {
                    type = "btrfs";
                    extraArgs = [ "-f" ];
                    subvolumes = {
                      "/root" = {
                        mountpoint = "/";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "/home" = {
                        mountpoint = "/home";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "/nix" = {
                        mountpoint = "/nix";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "/swap" = {
                        mountpoint = "/.swapvol";
                        swap.swapfile.size = "20M";
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  system.stateVersion = "24.11";
}
