{ den, ... }:
{
  den.hosts.x86_64-linux.clint-pc.users.csinger = { };

  den.aspects.clint-pc = {
    includes = with den.aspects; [
      gpu-nvidia-prime
      bluetooth
      sound
      plasma
      docker
      ssh
      flatpak
      qemu
      ai-tools
      tailscale
      sops
      determinate
      compat
      crypto
      tpm
      samba-client
      vscode-server

      browsers
      media-tools
      playwright
      azure-devops
    ];

    nixos =
      { pkgs, ... }:
      {
        # Hardware
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
        boot.kernelModules = [ "kvm-intel" ];
        boot.extraModprobeConfig = "options kvm_intel nested=1";

        # NVIDIA PRIME bus IDs (consumed by the gpu-nvidia-prime aspect).
        den.gpuPrime = {
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };

        # Filesystems
        # fileSystems."/" = {
        #   device = "/dev/disk/by-uuid/5ce2ae63-604b-4e22-9923-4dc1f479ade6";
        #   fsType = "ext4";
        # };
        # fileSystems."/boot" = {
        #   device = "/dev/disk/by-uuid/1454-A232";
        #   fsType = "vfat";
        # };
        # fileSystems."/mnt/data" = {
        #   device = "/dev/disk/by-uuid/f54eca10-f82e-4531-a24f-af500a7e45bf";
        #   fsType = "ext4";
        # };
        # swapDevices = [
        #   { device = "/dev/disk/by-uuid/9e72bc8a-7a48-4c4d-b180-6cd63a6aa1bd"; }
        # ];

        # # SMB share — tooling from samba-client aspect; credentials currently
        # # plaintext at /etc/nixos/.secret-smb (Phase 5 will SOPS-ize).
        # fileSystems."/mnt/backup" = {
        #   device = "//10.200.0.3/clint";
        #   fsType = "cifs";
        #   options = [
        #     "x-systemd.automount"
        #     "noauto"
        #     "x-systemd.idle-timeout=60"
        #     "x-systemd.device-timeout=5s"
        #     "x-systemd.mount-timeout=5s"
        #     "credentials=/etc/nixos/.secret-smb"
        #   ];
        # };

        # KASM compatibility — relaxed SSH MACs.
        services.openssh.settings.Macs = [
          "hmac-sha2-256-etm@openssh.com"
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256"
          "hmac-sha2-512"
        ];

        # Per-host values consumed by the azure-devops aspect.
        den.azureDevOps = {
          organization = "https://dev.azure.com/nueradev";
          project = "ProjectVicious";
        };

        # libvirt default connection (host-specific).
        environment.variables.LIBVIRT_DEFAULT_URI = "qemu:///system";

        # Generic system packages not covered by aspects.
        environment.systemPackages = with pkgs; [
          lsof
          nodejs
        ];

        disko.devices.disk = {
          main = {
            device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5P2NU0T800569N_1";
            # nvme-Samsung_SSD_980_PRO_1TB_S5P2NU0T800537P
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
      };
  };
}
