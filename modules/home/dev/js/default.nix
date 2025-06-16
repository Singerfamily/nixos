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
    webstorm = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable JetBrains WebStorm for JavaScript development.";
      };
    };
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config =
    let
      inherit (config.snowfall.dev.js)
        webstorm
        enable
        ;
    in
    mkIf enable {
      home.packages = with pkgs; [

        (mkIf webstorm.enable jetbrains.webstorm)

        node2nix
        nodejs
        deno

        nodePackages.pnpm
      ];
    };
}
