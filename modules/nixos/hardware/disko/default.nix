{
  lib, 
  config,
  ...
}: let 
  cfg = config.disko;
in {
  options.disko = with lib; {
    enable = mkEnableOption "Enable disk configuration";
    device = mkOption {
      type = types.str;
      description = "The disk device to install NixOS on";
    };
  };

  config = lib.mkIf cfg.enable {
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = cfg.device;
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
                  mountOptions = [
                    "defaults"
                  ];
                };
              };
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "crypted";
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
                        mountOptions = [ "compress=zstd" "noatime" ];
                      };
                      "/persist" = {
                        mountpoint = "/persist";
                        mountOptions = [ "subvol=persist" "compress=zstd" "noatime" ];
                      };
                      "/nix" = {
                        mountpoint = "/nix";
                        mountOptions = [ "subvol=nix" "compress=zstd" "noatime" ];
                      };
                      "/projects" = {
                        mountpoint = "/projects";
                        mountOptions = [ "subvol=projects" "compress=zstd" "noatime" ];
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