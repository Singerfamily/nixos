{ config, pkgs, lib, ... }:
let
  cfg = config.flatpak;
in {
  options = {
    flatpak = {
      enable = lib.mkEnableOption "Enable Flatpak";
    };
  };

  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;
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

    # services.flatpak.remotes = [{
    #   name = "flathub-beta"; location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
    # }];

    services.flatpak.packages = [
      "dev.vencord.Vesktop"
    ];
  };
}