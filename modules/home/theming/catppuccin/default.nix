{
  inputs,
  lib,
  config,
  ...
}:
with lib;

let
  inherit (config.snowfall.theming.catppuccin) enable;
  cfg = config.snowfall.theming.catppuccin;
in
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

    global = mkOption {
      description = "Enable Catppuccin theming globally.";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf enable {
    catppuccin = {
      enable = cfg.global;
      flavor = "mocha"; # Options: latte, frappe, macchiato, mocha
      # accent = "lavender";
    };
  };
}
