{ lib, config, ... }:
let
  cfg = config.programs.zoxide;
in
{
  programs.zoxide = lib.mkIf cfg.enable {
    enableZshIntegration = config.programs.zsh.enable;
    options = [
      "--cmd cd"
    ];
  };
}
