{ config, pkgs, lib, ... }:

with lib;
{
  options.snowfall.flatpak = {
    enable = mkOption{
      type = types.bool;
      default = false;
      description = "Whether to enable Flatpak support.";
    };
  };
  config = lib.mkIf config.snowfall.flatpak.enable {
    services.flatpak.enable = true;
    
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.kdePackages.xdg-desktop-portal-kde];
      config = {
        common = {
          default = [
            "kde"
          ];
        };
      };
    };
  };
}