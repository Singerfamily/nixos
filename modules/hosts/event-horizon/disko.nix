_:
{
  den.aspects.event-horizon.nixos =
    _:
    {
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
    };
}
