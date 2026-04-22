{ den, inputs, ... }:
{
  den.hosts.x86_64-linux.event-horizon.users.esinger = { };

  den.aspects.event-horizon = {
    includes = with den.aspects; [
      kernel-cachy
      gpu-amd
      bluetooth
      sound
      plasma
      docker
      ssh
      flatpak
      steam
      ai-tools
      opencode
      gemini-cli
      ollama
      tailscale
      netbird
      sops
      compat
      crypto
      tpm
    ];

    nixos =
      { config, pkgs, ... }:
      {
        imports = [ inputs.disko.nixosModules.disko ];

        # Hardware
        boot.initrd.availableKernelModules = [
          "nvme"
          "xhci_pci"
          "ahci"
          "usbhid"
          "sd_mod"
        ];
        boot.kernelModules = [ "kvm-amd" ];
        networking.hostId = "edc49e33";

        # Disko: primary NVMe with LUKS + Btrfs
        disko.devices.disk = {
          main = {
            device = "/dev/disk/by-id/nvme-CT1000P3SSD8_24234944EFA9";
            type = "disk";
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  type = "EF00";
                  size = "512M";
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
                    name = "EVENT-HORIZON_LUKS";
                    settings.allowDiscards = true;
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
            device = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_2TB_S6PNNM0TA16132B";
            type = "disk";
            content = {
              type = "gpt";
              partitions = {
                luks = {
                  size = "100%";
                  content = {
                    type = "luks";
                    name = "EVENT-HORIZON_GAMES_LUKS";
                    settings.allowDiscards = true;
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

        # CUPS printing
        services.printing = {
          enable = true;
          drivers = [ pkgs.hplipWithPlugin ];
        };
        services.avahi.enable = false;

        environment = {
          variables = {
            # For OpenBAO
            BAO_ADDR = "https://secrets.cleros.app";
          };
          systemPackages = with pkgs; [
            android-tools
            openbao
          ];
        };

        # KDE Connect
        programs.kdeconnect.enable = true;

      };
  };
}
