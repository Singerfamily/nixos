{ config, lib, pkgs, ... }:
with lib;
{
  options.snowfall.cli.eza = {
    enable = mkOption {
      description = "Whether to enable eza, a modern replacement for ls";
      type = with types; bool;
      default = true;
    };
  };

  config = mkIf config.snowfall.cli.eza.enable {
    home.packages = with pkgs; [
      eza
    ];
    
    programs.eza = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      git = true;
    };
  };
}
