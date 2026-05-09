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
      tailscale
      sops
      determinate
      compat
      crypto
      tpm
      vscode-server
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
          "dm-raid"
          "dm-mirror"
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

        disko.devices =
          let
            disks = [
              "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5P2NU0T800569N_1"
              "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5P2NU0T800537P"
            ];
          in
          {
            disk = {
              disk1 = {
                type = "disk";
                device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5P2NU0T800569N_1";
                content = {
                  type = "gpt";
                  partitions = {
                    BOOT = {
                      size = "512M";
                      type = "EF02"; # for grub MBR
                    };
                    ESP = {
                      size = "500M";
                      type = "EF00";
                      content = {
                        type = "mdraid";
                        name = "boot";
                      };
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
                    BOOT = {
                      size = "512M";
                      type = "EF02"; # for grub MBR
                    };
                    ESP = {
                      size = "500M";
                      type = "EF00";
                      content = {
                        type = "mdraid";
                        name = "boot";
                      };
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
              boot = {
                type = "mdadm";
                level = 1; # Use RAID 1 for boot (mirrored)
                metadata = "1.0"; # Critical for bootability [1](#3-0)
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              raid0 = {
                type = "mdadm";
                level = 0; # RAID 0 for striping [2](#3-1)
                content = {
                  type = "btrfs";
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
                  };
                };
              };
            };
          };
      };
  };
}
