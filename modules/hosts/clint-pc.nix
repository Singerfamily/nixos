{ den, inputs, ... }:
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
        imports = [ inputs.disko.nixosModules.disko ];

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

        disko.devices = {
          disk = {
            disk1 = {
              type = "disk";
              device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5P2NU0T800569N_1";
              content = {
                type = "gpt";
                partitions = {
                  boot = {
                    size = "1M";
                    type = "EF02"; # for grub MBR
                  };
                  mdadm = {
                    size = "100%";
                    content = {
                      type = "mdraid";
                      name = "raid0";
                    };
                  };
                };
              };
            };
            disk2 = {
              type = "disk";
              device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5P2NU0T800537P";
              content = {
                type = "gpt";
                partitions = {
                  boot = {
                    size = "1M";
                    type = "EF02"; # for grub MBR
                  };
                  mdadm = {
                    size = "100%";
                    content = {
                      type = "mdraid";
                      name = "raid0";
                    };
                  };
                };
              };
            };
          };
          mdadm = {
            raid0 = {
              type = "mdadm";
              level = 0;
              content = {
                type = "gpt";
                partitions = {
                  ESP = {
                    priority = 1;
                    name = "ESP";
                    start = "1M";
                    end = "128M";
                    type = "EF00";
                    content = {
                      type = "filesystem";
                      format = "vfat";
                      mountpoint = "/boot";
                      mountOptions = [ "umask=0077" ];
                    };
                  };
                  root = {
                    size = "100%";
                    content = {
                      type = "btrfs";
                      extraArgs = [ "-f" ]; # Override existing partition
                      # Subvolumes must set a mountpoint in order to be mounted,
                      # unless their parent is mounted
                      subvolumes = {
                        # Subvolume name is different from mountpoint
                        "/rootfs" = {
                          mountpoint = "/";
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        # Subvolume name is the same as the mountpoint
                        "/home" = {
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                          mountpoint = "/home";
                        };
                        # Parent is not mounted so the mountpoint must be set
                        "/nix" = {
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                          mountpoint = "/nix";
                        };
                        # Subvolume for the swapfile
                        "/swap" = {
                          mountpoint = "/.swapvol";
                          swap = {
                            swapfile.size = "20M";
                          };
                        };
                      };

                      mountpoint = "/partition-root";
                      swap = {
                        swapfile = {
                          size = "20M";
                        };
                        swapfile1 = {
                          size = "20M";
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
