{ lib, config, ... }:
let
  cfg = config.programs.fzf;
in
{
  programs.fzf = lib.mkIf cfg.enable {
    enableZshIntegration = config.programs.zsh.enable;
  };
}
