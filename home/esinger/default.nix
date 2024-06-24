{config, pkgs, ...}: {
  programs = {
    git = {
      enable = true;
      userName = "LeaderbotX400";
      userEmail = "eric@singerfamily.ca";
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd cd"
      ];
    };

    fzf.enable = true;

    zsh = {
      enable = true;

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        ll = "ls -l";
        la = "ls -la";
        update = "sudo nixos-rebuild switch --flake $HOME/nixos";
      };

      promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";

      ohMyZsh = {
        enable = true;
        plugins = [
          "git"
          "npm"
          "history"
          "node"
        ];
      };
    };
  };
}