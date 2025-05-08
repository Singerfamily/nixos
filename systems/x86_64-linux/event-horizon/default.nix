# INFO: Illusion, a virtual machine.

{
  config,
  lib,
  pkgs,
  ...
}:

{
  aeon = {

    apps = {
      steam.enable = true;
    };

    boot = {
      type = "lanzaboote";
      # quiet = true;
      # encrypted = true;
    };

    fs.type = "btrfs";
    docker = {
      enable = true;
      implementation = "both";
    };

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
    net = {
      ssh.server = true;
    };

    tpm.enable = true;
  };

  # programs = {
  #   spotify.enable = true;
  #   steam.enable = true;
  #   # thunderbird.enable = true;
  #   firefox.enable = true;
  #   nix-ld.enable = true;

  #   # snapmaker-luban.enable = true;
  # };

  environment = {
    variables = {
      NIXOS_OZONE_WL = "1";
    };

    systemPackages = with pkgs; [
      dbeaver-bin
      r2modman
      modrinth-app
      appimage-run
      wine

      # Dotnet
      jetbrains.rider
      jetbrains.datagrip
      dotnet-sdk_9

      # JS / TS
      nodejs
      nodePackages.pnpm
      deno
    ];
  };

  hardware = {
    openrazer = {
      enable = true;
      users = [ "esinger" ];
    };
  };

  disko.devices =
    let
      inherit (config.networking) hostName;
    in
    {
      disk."nvme0n1" = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            efi = {
              priority = 1;
              name = "NIXOS_EFI";
              size = "256M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "${lib.toUpper hostName}_LUKS";
                settings.allowDiscards = true;
                content = {
                  type = "lvm_pv";
                  vg = "${lib.toLower hostName}";
                };
              };
            };
          };
        };
      };

      lvm_vg."${lib.toLower hostName}" = {
        type = "lvm_vg";
        lvs.root = {
          size = "100%FREE";
          content = {
            type = "btrfs";
            extraArgs = [ "--force" ];
            subvolumes =
              let
                mountOptions = [
                  "compress=zstd"
                  "space_cache=v2"
                ];
              in
              {
                "@" = {
                  mountpoint = "/";
                  inherit mountOptions;
                };
                "@home" = {
                  mountpoint = "/home";
                  inherit mountOptions;
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = mountOptions ++ [ "noatime" ];
                };
              };
          };
        };
      };
    };

  # NOTE: Flattened for the installer script.

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/run/media/games" = {
    device = "/dev/disk/by-uuid/14A4A219A4A1FD7C";
    fsType = "ntfs-3g";
    options = [ "uid=1000,gid=100,forceuid,forcegid" ];
  };

  system.stateVersion = "24.11"; # WARN: Changing this might break things. Just leave it.
  networking.hostId = "73954873"; # Needed for ZFS machine identification.
}
