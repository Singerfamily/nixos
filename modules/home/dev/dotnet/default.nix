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
    rider = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable JetBrains Rider for .NET development.";
      };
    };
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config =
    let
      inherit (config.snowfall.dev.dotnet)
        enable
        rider
        ;
    in
    mkIf enable {
      home.packages = with pkgs; [
        (mkIf rider.enable jetbrains.rider)
        dotnet-sdk_9
        # dotnetCorePackages.dotnet_9.sdk
      ];
    };
}
