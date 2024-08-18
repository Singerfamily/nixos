{ self, config, lib, pkgs, ... }: let
  cfg = config.programs.zsh;
in {
  config = lib.mkIf cfg.enable {
    home.file.".p10k.zsh".source = "${self}/zsh/p10k.zsh";

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
          update = "sudo nixos-rebuild switch --flake $HOME";
        };

        plugins = [
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
          {
            name = "powerlevel10k-config";
            src = lib.cleanSource "${self}/zsh";
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
  };
}