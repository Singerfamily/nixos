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
        enable
        ;
    in
    mkIf enable {
      home.packages = with pkgs; [

        jetbrains.webstorm

        node2nix
        nodejs
        deno

        nodePackages.pnpm
      ];
    };
}
