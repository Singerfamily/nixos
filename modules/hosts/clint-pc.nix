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
      ollama-proxy
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
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ "kvm-intel" ];
        boot.extraModulePackages = [ ];

        boot.extraModprobeConfig = "options kvm_intel nested=1";

        # NVIDIA PRIME bus IDs (consumed by the gpu-nvidia-prime aspect).
        den.gpuPrime = {
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };

        # Filesystems

        services.ollama = {
          enable = true;
          loadModels = [
            "gemma4:31b"
          ];
        };

        # Bearer-token auth + network exposure for ollama (ollama-proxy aspect).
        # The API key lives in secrets/hosts/clint-pc.yaml under "ollama/api-key".
        den.ollamaProxy.enable = true;
        sops.secrets."ollama/api-key" = {
          sopsFile = ../../secrets/hosts/clint-pc.yaml;
        };

        # KASM compatibility — relaxed SSH MACs.
        services.openssh.settings.Macs = [
          "hmac-sha2-256-etm@openssh.com"
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256"
          "hmac-sha2-512"
        ];

        # Per-host values consumed by the azure-devops aspect.
        # den.azureDevOps = {
        #   organization = "https://dev.azure.com/nueradev";
        #   project = "ProjectVicious";
        # };

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
              main = {
                type = "disk";
                device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5P2NU0T800569N_1";
                content = {
                  type = "gpt";
                  partitions = {
                    ESP = {
                      priority = 1;
                      name = "ESP";
                      size = "512M";
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
                          "/root" = {
                            mountOptions = [
                              "compress=zstd"
                              "noatime"
                            ];
                            mountpoint = "/";
                          };
                          "/home" = {
                            mountOptions = [
                              "compress=zstd"
                              "noatime"
                            ];
                            mountpoint = "/home";
                          };
                          "/nix" = {
                            mountOptions = [
                              "compress=zstd"
                              "noatime"
                            ];
                            mountpoint = "/nix";
                          };
                        };
                      };
                    };
                  };
                };
              };

              data = {
                type = "disk";
                device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5P2NU0T800537P";
                content = {
                  type = "gpt";
                  partitions = {
                    root = {
                      size = "100%";
                      content = {
                        type = "btrfs";
                        extraArgs = [ "-f" ]; # Override existing partition
                        # Subvolumes must set a mountpoint in order to be mounted,
                        # unless their parent is mounted
                        subvolumes = {
                          # Subvolume name is different from mountpoint
                          "/mnt/data" = {
                            mountOptions = [
                              "compress=zstd"
                              "noatime"
                            ];
                            mountpoint = "/mnt/data";
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
