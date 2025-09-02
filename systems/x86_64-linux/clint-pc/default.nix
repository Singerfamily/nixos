{
  lib,
  pkgs,
  config,
  ...
}:
{
  snowfall = {
    boot = {
      type = "uefi";
    };

    docker = {
      enable = true;
    };

    flatpak.enable = true;

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

    qemu.enable = true;

    net.ssh = {
      enable = true;
      server = true; # Allow SSH'ing into this machine
    };
  };

  programs = {
    firefox.enable = true;
  };

  services = {
    vscode-server.enable = true;
    # udev = {
    #   packages = [
    #     pkgs.platformio-core
    #     pkgs.openocd
    #   ];
    #   extraRules = ''
    #     # udev rule for ST-LINK/V2
    #     SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE:="0666", SYMLINK+="stlinkv2_%n"
    #   '';
    # };
    # nginx = {
    #   enable = true;

    #   # Use recommended settings
    #   recommendedZstdSettings = true;
    #   # recommendedBrotliSettings = true;
    #   # recommendedGzipSettings = true;
    #   recommendedOptimisation = true;
    #   recommendedProxySettings = true;
    #   recommendedTlsSettings = true;

    #   # other Nginx options
    #   virtualHosts."nucos" =
    #     let
    #       tls-cert =
    #         {
    #           alt ? [ ],
    #         }:
    #         (pkgs.runCommand "selfSignedCert" { buildInputs = [ pkgs.openssl ]; } ''
    #           mkdir -p $out
    #           openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 -days 365 -nodes \
    #             -keyout $out/cert.key -out $out/cert.crt \
    #             -subj "/CN=localhost" -addext "subjectAltName=DNS:localhost,${
    #               builtins.concatStringsSep "," ([ "IP:127.0.0.1" ] ++ alt)
    #             }"
    #         '');
    #       cert = tls-cert { alt = [ "IP:192.168.1.131" ]; };
    #     in
    #     {
    #       addSSL = true;

    #       sslCertificate = "${cert}/cert.crt";
    #       sslCertificateKey = "${cert}/cert.key";

    #       locations."/" = {
    #         proxyPass = "http://127.0.0.1:3000";
    #         proxyWebsockets = true; # needed if you need to use WebSocket
    #       };
    #       locations."/obs-ws" = {
    #         proxyPass = "http://127.0.0.1:4455";
    #         proxyWebsockets = true; # needed if you need to use WebSocket
    #       };
    #     };
    # };
  };

  environment = {
    variables = {
      NIXOS_OZONE_WL = "1";
      # OPENOCD_PATH = "${pkgs.openocd}";
      # OPENOCD_SCRIPTS_PATH = "$OPENOCD_PATH/share/openocd/scripts";
    };
    systemPackages = with pkgs; [
      # obs-studio
      # talosctl
      # python3
      # python312Packages.pyudev

      # platformio-core
      # (pkgs.python3.withPackages (ps: with ps; [ platformio ]))

      # stlink
      # openocd
      # gdb
      # cmake
      # gcc
      # stm32cubemx
      # gcc-arm-embedded-13
    ];
  };

  # networking.firewall.allowedTCPPorts = [
  #   80
  #   443
  # ];
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/md-uuid-4b21de7f:f29ca007:298b5060:1dacafb5";
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
                  };
                  # Subvolume name is the same as the mountpoint
                  "/home" = {
                    mountOptions = [ "compress=zstd" ];
                    mountpoint = "/home";
                  };
                  # Sub(sub)volume doesn't need a mountpoint as its parent is mounted
                  "/home/user" = { };
                  # Parent is not mounted so the mountpoint must be set
                  "/nix" = {
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                    mountpoint = "/nix";
                  };
                  # This subvolume will be created but not mounted
                  "/test" = { };
                  # Subvolume for the swapfile
                  "/swap" = {
                    mountpoint = "/.swapvol";
                    swap = {
                      swapfile.size = "20M";
                      swapfile2.size = "20M";
                      swapfile2.path = "rel-path";
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

  # DANGER - Do not Modify Below!

  boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "ahci" "thunderbolt" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp4s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp6s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp5s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # networking.hostId = "007f0200";

  system.stateVersion = "24.11";
}
