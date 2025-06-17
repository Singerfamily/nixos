{
  inputs,
  lib,
  config,
  ...
}:
with lib;
{
  options.snowfall.theming.catppuccin = {
    enable = mkEnableOption "Catppuccin theming";
  };

  config = mkIf config.snowfall.theming.catppuccin.enable {
    imports = with inputs; [
      catppuccin.homeModules.catppuccin
    ];

    # Enable catppuccin theming for various applications
    programs.catppuccin = {
      enable = true;
      style = "mocha"; # Options: latte, frappe, macchiato, mocha
    };

    catppuccin = {
      flavor = "mocha";
      # accent = "lavender";
    };

    # # Enable catppuccin theming for k9s
    # catppuccin.k9s.enable = true;

    # # Enable catppuccin theming for starship
    # catppuccin.starship.enable = true;
  };
}
