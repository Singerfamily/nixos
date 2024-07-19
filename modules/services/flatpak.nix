{ config, lib, ... }:
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
    xdg.portal.enable = true;

    # services.flatpak.remotes = [{
    #   name = "flathub-beta"; location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
    # }];

    services.flatpak.packages = [
      "dev.vencord.Vesktop"
    ];
  };
}