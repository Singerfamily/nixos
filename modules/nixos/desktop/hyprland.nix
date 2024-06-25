{inputs, pkgs, ...}: {
  programs.hyprland.enable = true;
  # programs = {
  #   hyprland = {
  #     enable = true;
  #     package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  #   };
    
  #   hyprlock.enable = true;
  # };

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
  ];
}