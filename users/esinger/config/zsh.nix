{pkgs, lib, ...}: {
  programs = {

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

      initExtra = ''
        cp ~/.zsh_history ~/.zsh_history.bak
        strings ~/.zsh_history.bak > ~/.zsh_history
        fc -R ~/.zsh_history

        export XDG_DATA_HOME="$HOME/.local/share"
      '';

      shellAliases = {
        ll = "ls -l";
        la = "ls -la";
        update = "$HOME/nixos/helpers/upgrade.sh";
      };

      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "powerlevel10k-config";
          src = lib.cleanSource ./p10k;
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
}