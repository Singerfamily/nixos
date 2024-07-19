{config, lib}: {
  imports = [
    ./plasma.nix
    ./hyprland.nix
  ];

  options = {
    desktop = lib.mkStringOption {
      default = "plasma";
      description = "The desktop environment to use";
    };
  };

  config = {
    config.plasma.enable = config.desktop == "plasma";
    config.hyprland.enable = config.desktop == "hyprland";
  };
}