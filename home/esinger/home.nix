{pkgs, lib, ...}: {
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

      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "powerlevel10k-config";
          src = lib.cleanSource ./config/zsh;
          file = "p10k.zsh";
        }
      ];

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
        ];
      };
    };
  };

  home.stateVersion = "24.05";
}