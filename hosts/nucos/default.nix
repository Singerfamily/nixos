{ pkgs, lib, ... }:
let

  pythonDeps =
    with pkgs.python3Packages;
    [
      pandas
      requests
      pyudev
      docker
      psutil
      tabulate
      google-api-python-client
      google-auth
      google-auth-oauthlib
      google-auth-httplib2
      fastapi
      pip
      uvicorn
      pyinstaller
    ]
    ++ (with pkgs.python3Packages; [
      (buildPythonPackage rec {
        pname = "linuxpy";
        version = "0.20.0";

        src = pkgs.fetchFromGitHub {
          owner = "tiagocoutinho";
          repo = "linuxpy";
          rev = "v${version}";
          sha256 = "sha256-8gJu3WxBAVqr72Hd2UUmsWiNVrFa81Vd/fCPmO/pQcg=";
        };
      })
    ]);

  pbs = pkgs.stdenv.mkDerivation {
    name = "pbs";
    src = /home/csinger/Projects/PBS/pbs;
    buildInputs = [ pkgs.python3 ] ++ pythonDeps;
    propagatedBuildInputs = pythonDeps;

    buildPhase = ''
      pyinstaller --distpath ../dist --workpath ../build --log-level TRACE  ./main.py
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp -r ../dist/main $out/bin/pbs
    '';
  };
in
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

  services = {
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

  systemd.services.pbs = {
    enable = true;

    serviceConfig = {
      type = "simple";
      ExecStart = "${pbs}/bin/pbs/main";
      Restart = "on-failure";
      RemainAfterExit = "yes";
    };

    wantedBy = [ "multi-user.target" ];
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
        locations."/api" = {
          proxyPass = "http://127.0.0.1:4421";
          proxyWebsockets = true;
          extraConfig = ''
            rewrite ^/api/(.*)$ /$1 break;
          '';
        };
      };
  };
}
