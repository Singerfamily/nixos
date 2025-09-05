# INFO: ruby Home-manager module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.dev.ruby = {

    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config =
    let
      inherit (config.snowfall.dev.ruby)
        enable
        ;
    in
    mkIf enable {
      home =
        {
          packages = with pkgs; [
            ruby
          ];
        };
    };
}
