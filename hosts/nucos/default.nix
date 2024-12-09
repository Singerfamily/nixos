{ pkgs, lib, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  drivers = {
    nvidia.enable = true;
    intel.enable = true;
  };

  programs = {
    firefox.enable = true;
    nix-ld.enable = true;
  };

  # desktop.plasma.enable = lib.mkForce false;

  services = {
    # pipewire.enable = lib.mkForce false;
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
  };

  virtualisation = {
    docker.enable = true;
  };

  # hardware = {
  #   pulseaudio = {
  #     enable = true;
  #     systemWide = true;
  #   };
  # };

  environment = {
    systemPackages = with pkgs; [
      obs-studio

      python3
      python312Packages.pyudev

      platformio-core
      (pkgs.python3.withPackages (ps: with ps; [ platformio ]))

      stlink
      openocd

      gdb
    ];

    variables = {
      OPENOCD_PATH = "${pkgs.openocd}";
      OPENOCD_SCRIPTS_PATH = "$OPENOCD_PATH/share/openocd/scripts";
    };
  };

  # TRAEFIK

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.nginx = {
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
}
