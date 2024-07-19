{inputs, pkgs, ...}: {
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
}