{pkgs, ...}: {
  home.username = "esinger";
  home.homeDirectory = "/home/esinger";

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

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        ll = "ls -l";
        la = "ls -la";
        update = "sudo nixos-rebuild switch --flake $HOME/nixos";
      };

      # initExtra = ''
      #   source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
      # '';

      oh-my-zsh = {
        enable = true;
        theme = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        plugins = [
          "git"
          "zsh-autosuggestions"
          "zsh-syntax-highlighting"
        ];
      };
    };
  };
}