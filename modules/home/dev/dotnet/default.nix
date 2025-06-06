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
      home.packages = with pkgs; [
        jetbrains.rider
        dotnet-sdk_9
        dotnet-ef
      ];
    };
}
