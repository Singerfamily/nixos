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
        games = {
          type = "disk";
          device = "/dev/sdb";
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
        cold-storage = {
          type = "disk";
          device = "/dev/sda";
          content = {
            type = "gpt";
            partitions = {
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "${lib.toUpper hostName}_COLD-STORAGE_LUKS";
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
                        mountpoint = "/mnt/cold-storage";
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
