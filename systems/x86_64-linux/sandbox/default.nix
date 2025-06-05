{
    # Snowfall Lib provides a customized `lib` instance with access to your flake's library
    # as well as the libraries available from your flake's inputs.
    lib,
    # An instance of `pkgs` with your overlays and packages applied is also available.
    pkgs,
    # You also have access to your flake's inputs.
    inputs,

    # Additional metadata is provided by Snowfall Lib.
    namespace, # The namespace used for your flake, defaulting to "internal" if not set.
    system, # The system architecture for this host (eg. `x86_64-linux`).
    target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
    format, # A normalized name for the system target (eg. `iso`).
    virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
    systems, # An attribute map of your defined hosts.

    # All other arguments come from the system system.
    config,
    ...
}:
{
  snowfall = {
    boot = {
      type = "bios"; # Use UEFI bootloader
      # encrypted = true; # Enable LUKS2 encryption
      # quiet = true; # Enable Plymouth and reduce TTY verbosity
    };
  };

  services = {
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      autoNumlock = true;
    };
    desktopManager.plasma6.enable = true;
  };

  environment.systemPackages =
    with pkgs;
    [
      aha
      fwupd
      vulkan-tools
      wayland-utils
      pciutils
    ]
    ++ (with pkgs.kdePackages; [
      discover
      kaccounts-integration
      kaccounts-providers
      plasma-browser-integration
      plasma-disks
      kalk
      partitionmanager
      krdc
      (lib.mkIf config.services.hardware.bolt.enable plasma-thunderbolt)
    ]);

  users.users."esinger" = {
    hashedPassword = "$y$j9T$Y9uPcCDrepfHHZkw.r6wM1$5oEosCGb3J2R6024/AGYg/lgekaAiGoEMFk/h6GHXGC";
    # isNormalUser = true;
    # name = "esinger";
    # shell = pkgs.zsh;
    # description = "Eric Singer";
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager"
      "tss"
    ];
  };

  disko.devices = 
    let
      inherit (config.networking) hostName;
    in
    {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
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
    };
  };

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

  system.stateVersion = "24.11";
}