# INFO: Jetbrains Home-manager module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.dev.jetbrains = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config =
    let
      inherit (config.snowfall.dev.jetbrains)
        enable
        ;

      inherit (config.snowfall) dev;
    in
    mkIf enable {
      home.packages =
        with pkgs.jetbrains;
        with dev;
        [
          (mkIf python.enable pycharm-community)
          (mkIf js.enable webstorm)
          (mkIf dotnet.enable rider)
        ];
    };
}
