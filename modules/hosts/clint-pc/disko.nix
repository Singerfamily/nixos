_:
{
  den.aspects.clint-pc.nixos =
    _:
    {
      disko.devices.disk = {
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
                  extraArgs = [ "-f" ];
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
                  extraArgs = [ "-f" ];
                  subvolumes = {
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
}
