{pkgs, ...}: {
  programs = {
    hyprland.enable = true;
    hyprlock.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  environment.systemPackages = with pkgs; [
    waybar
    hyprpaper
    kitty
    dunst
    libnotify
    rofi-wayland
    (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
    }))
  ];
}