# INFO: Javascript Home-manager module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.dev.js = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config =
    let
      inherit (config.snowfall.dev.js)
        # webstorm
        enable
        ;
    in
    mkIf enable {
      home.packages = with pkgs; [

        # (mkIf webstorm.enable jetbrains.webstorm)

        node2nix
        nodejs

        nodePackages.pnpm
      ];
    };
}
