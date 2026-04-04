{ den, ... }:
{
  # Zsh aspect - rich zsh config with powerlevel10k
  # Use via: den.aspects.<user>.includes = [ (den.provides.user-shell "zsh") den.aspects.zsh ];
  den.aspects.zsh.homeManager =
    { pkgs, lib, ... }:
    {
      programs.zsh = {
        autosuggestion.enable = lib.mkDefault true;
        syntaxHighlighting.enable = lib.mkDefault true;
        oh-my-zsh = {
          enable = lib.mkDefault true;
          plugins = lib.mkDefault [ "git" ];
        };
        plugins = [
          {
            name = "powerlevel10k";
            src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
            file = "powerlevel10k.zsh-theme";
          }
          {
            name = "powerlevel10k-config";
            src = ../../../dotfiles;
            file = "p10k.zsh";
          }
        ];
      };
    };
}
