{inputs, pkgs, ...}: let
  cfg = config.hyprland;
in {

  options = {
    hyprland = {
      enable = pkgs.lib.mkEnableOption "Enable Hyprland";
    };
  };

  config = lib.mkIf cfg.enable {

    programs = {
      hyprland.enable = true;
      waybar.enable = true; 
      hyprlock.enable = true;
    };

    # xdg.portal = {
    #   enable = true;
    #   extraPortals = [pkgs.xdg-desktop-portal-gtk];
    # };

    environment.systemPackages = with pkgs; [
      kitty
      dunst
      libnotify
      hyprpaper

      rofi-wayland

      inputs.pyprland.packages.${pkgs.system}.pyprland
    ];
  };
}