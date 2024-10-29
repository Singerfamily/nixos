{
  config,
  lib,
  pkgs,
  homeModules,
  homeConfiguration,
  username,
  ...
}:
let
  cfg = config.programs.zsh;
in
{

  home.file.".p10k.zsh".source = "${homeConfiguration}/${username}/zsh/p10k.zsh";

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

    zsh = lib.mkIf cfg.enable {
      enable = true;

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      initExtra = ''
        cp ~/.zsh_history ~/.zsh_history.bak
        strings ~/.zsh_history.bak > ~/.zsh_history
        fc -R ~/.zsh_history

        export XDG_DATA_HOME="$HOME/.local/share"
        eval "$(tailscale completion zsh)"
      '';

      shellAliases = {
        ll = "ls -l";
        la = "ls -la";
        update = "sudo nixos-rebuild switch --flake $HOME";
      };

      plugins = [
        {
          name = "powerlevel10k";
          src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
          file = "powerlevel10k.zsh-theme";
        }
        {
          name = "powerlevel10k-config";
          src = lib.cleanSource "${homeModules}/zsh";
          file = "p10k.zsh";
        }
      ];

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "kubectl"
        ];
      };
    };
  };
}
