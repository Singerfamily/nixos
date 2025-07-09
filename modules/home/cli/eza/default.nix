{ config, lib, ... }:
with lib;
{
  options.snowfall.cli.eza = {
    enable = mkOption {
      description = "Whether to enable eza, a modern replacement for ls";
      type = with types; bool;
      default = false;
    };
  };

  config = mkIf config.snowfall.cli.eza.enable {
    programs.eza = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      git = true;
    };

    programs.bash = {
      enable = true;
      initExtra = ''
        if [ -f "${config.programs.eza.package}/share/bash-completion/completions/eza" ]; then
          . "${config.programs.eza.package}/share/bash-completion/completions/eza"
        fi
      '';
    };
  };
}
