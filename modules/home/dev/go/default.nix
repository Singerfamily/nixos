# INFO: Home-manager C/C++ module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.dev.go = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.snowfall.dev.c.enable {
    home.packages = with pkgs; [
      go
      gopls
      gotools
      go-tools
    ];
  };
}
