# INFO: General Dev Home-manager module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.dev.core = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config =
    let
      inherit (config.snowfall.dev.core)
        enable
        ;
    in
    mkIf enable {
      home.packages = with pkgs; [
        typos # Source code spell checker.
        graphviz # Graph visualization tools.
      ];
    };
}
