{
  pkgs,
  lib,
  config,
  ...
}:
let
  version = "4.13.1-beta.2.3.2";
in
{
  options.programs.snapmaker-luban = {
    enable = lib.mkEnableOption "Enable Snapmaker Luban";
  };

  config = lib.mkIf {
    environment.systemPackages = [
      (pkgs.snapmaker-luban.overrideAttrs (oldAttrs: {
        inherit version;
        # version = "4.13.1-beta.2.3.2";
        src = pkgs.fetchurl {
          url = "https://github.com/Snapmaker/Luban/releases/download/v${version}/snapmaker-luban-${version}-linux-x64.tar.gz";
          sha256 = "sha256-VNIuOsRTS5qsq4IK1G6NSidNNEgziHGTNGvDKwjPO70=";
        };
      }))
    ];

    nixpkgs.config.permittedInsecurePackages = [
      "snapmaker-luban-${version}"
    ];
  };
}
