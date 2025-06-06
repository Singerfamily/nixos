# INFO: Javascript Home-manager module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.dev.python = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config =
    let
      inherit (config.snowfall.dev.python)
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
