{ config, pkgs, lib, ... }:
let
  cfg = config.services.flatpak;
in {
  config = lib.mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-kde];
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