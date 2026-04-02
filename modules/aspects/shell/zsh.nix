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
      };
      home.packages = [ pkgs.zsh-powerlevel10k ];
      home.file.".p10k.zsh".source = lib.mkDefault ../../../dotfiles/p10k.zsh;
      programs.zsh.initContent = lib.mkDefault ''
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      '';
    };
}
