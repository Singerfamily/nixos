{
  lib,
  pkgs,
  config,
  ...
}:
{
  snowfall = {
    boot = {
      type = "lanzaboote"; # Use UEFI bootloader
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
        intel.enable = true;
        amd.enable = true;
      };
    };

    apps = {
      steam.enable = true;
    };

    qemu.enable = true;
  };

  programs = {
    kdeconnect.enable = true;
    # vscode.enable = true;
  };

  services = {
    vscode-server.enable = true;
  };

  environment = {
    variables = {
      NIXOS_OZONE_WL = "1";
    };
  };

  fileSystems."/mnt/media" = {
    device = "192.168.1.3:/mnt/stuff/media";
    fsType = "nfs";
  };

  disko.devices =
    let
      inherit (config.networking) hostName;
    in
    {
      disk = {
        main = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-CT1000P3SSD8_24234944EFA9";
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
                        swap.swapfile.size = "32G";
                      };
                    };
                  };
                };
              };
            };
          };
        };
        games = {
          type = "disk";
          device = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_2TB_S6PNNM0TA16132B";
          content = {
            type = "gpt";
            partitions = {
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "${lib.toUpper hostName}_GAMES_LUKS";
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
                      "/" = {
                        mountpoint = "/mnt/games";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
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

  networking.hostId = "edc49e33";

  system.stateVersion = "24.11";
}
