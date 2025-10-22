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

    home.shellAliases = {
      ls = mkDefault "${pkgs.eza}/bin/eza --group-directories-first --color=auto --hyperlink";
      ll = mkDefault "ls -la";
      lla = mkDefault "ls -la --all";
      tree = mkDefault "ls --tree --level=3";
    };
    
    programs.eza = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      git = true;
    };
  };
}
