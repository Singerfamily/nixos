# INFO: Dotnet Home-manager module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.dev.dotnet = {

    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config =
    let
      inherit (config.snowfall.dev.dotnet)
        enable
        ;
    in
    mkIf enable {
      home =
        let
          sdk = (with pkgs.dotnetCorePackages; combinePackages [ sdk_10_0_1xx-bin ]);
        in
        {
          packages = with pkgs; [
            sdk
            dotnet-ef
          ];

          sessionVariables = {
            DOTNET_PATH = "${sdk}/bin/dotnet";
            DOTNET_ROOT = "${sdk}/share/dotnet";
          };
        };
    };
}
