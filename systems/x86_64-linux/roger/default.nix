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
    udev = {
      packages = [
        pkgs.platformio-core
        pkgs.openocd
      ];
      extraRules = ''
        # udev rule for ST-LINK/V2 
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE:="0666", SYMLINK+="stlinkv2_%n"
      '';
    };
    nginx = {
      enable = true;

      # Use recommended settings
      recommendedZstdSettings = true;
      # recommendedBrotliSettings = true;
      # recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      # other Nginx options
      virtualHosts."nucos" =
        let
          tls-cert =
            {
              alt ? [ ],
            }:
            (pkgs.runCommand "selfSignedCert" { buildInputs = [ pkgs.openssl ]; } ''
              mkdir -p $out
              openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 -days 365 -nodes \
                -keyout $out/cert.key -out $out/cert.crt \
                -subj "/CN=localhost" -addext "subjectAltName=DNS:localhost,${
                  builtins.concatStringsSep "," ([ "IP:127.0.0.1" ] ++ alt)
                }"
            '');
          cert = tls-cert { alt = [ "IP:192.168.1.131" ]; };
        in
        {
          addSSL = true;

          sslCertificate = "${cert}/cert.crt";
          sslCertificateKey = "${cert}/cert.key";

          locations."/" = {
            proxyPass = "http://127.0.0.1:3000";
            proxyWebsockets = true; # needed if you need to use WebSocket
          };
          locations."/obs-ws" = {
            proxyPass = "http://127.0.0.1:4455";
            proxyWebsockets = true; # needed if you need to use WebSocket
          };
        };
    };
  };

  environment = {
    variables = {
      NIXOS_OZONE_WL = "1";
      OPENOCD_PATH = "${pkgs.openocd}";
      OPENOCD_SCRIPTS_PATH = "$OPENOCD_PATH/share/openocd/scripts";
    };
    systemPackages = with pkgs; [
      obs-studio
      talosctl
      python3
      python312Packages.pyudev

      platformio-core
      (pkgs.python3.withPackages (ps: with ps; [ platformio ]))

      stlink
      openocd
      gdb
      cmake
      gcc
      stm32cubemx
      gcc-arm-embedded-13
    ];
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8936eed1-ba38-47d9-aa87-819a2ac1bb9d";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/013A-5554";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  networking.hostId = "007f0200";

  system.stateVersion = "24.11";
}
