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
    mkIf enable (
      with dev;
      {
        home.packages =
          with pkgs.jetbrains;
          [
            (mkIf python.enable pycharm)
            (mkIf js.enable webstorm)
            (mkIf dotnet.enable rider)
            (mkIf rust.enable rust-rover)
            (mkIf ruby.enable ruby-mine)
            (mkIf java.enable idea)
            (mkIf c.enable clion)
            # (mkIf go.enable goland)
          ];
      }
    );
}
