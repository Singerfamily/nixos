{
  inputs,
  lib,
  config,
  ...
}:
with lib;
{
  imports = with inputs; [
    catppuccin.homeModules.catppuccin
  ];

  options.snowfall.theming.catppuccin = {
    enable = mkOption {
      description = "Enable Catppuccin theming for various applications.";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf config.snowfall.theming.catppuccin.enable {
    catppuccin = {
      enable = true;
      flavor = "mocha"; # Options: latte, frappe, macchiato, mocha
      # accent = "lavender";
    };
  };
}
