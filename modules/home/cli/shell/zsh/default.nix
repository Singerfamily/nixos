{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (config.snowfall.cli.shell.default == "zsh") {

    home.packages = with pkgs; [
      zsh-powerlevel10k
    ];

    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      plugins = [
        {
          name = "powerlevel10k";
          src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
          file = "powerlevel10k.zsh-theme";
        }
        # {
        #   name = "powerlevel10k-config";
        #   src = lib.cleanSource "${userCfgPath}/zsh";
        #   file = "p10k.zsh";
        # }
      ];

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "kubectl"
        ];
      };
    };

    # initContent = ''
    #     cp ~/.zsh_history ~/.zsh_history.bak
    #     strings ~/.zsh_history.bak > ~/.zsh_history
    #     fc -R ~/.zsh_history

    #     export XDG_DATA_HOME="$HOME/.local/share"
    #     eval $(tailscale completion zsh)
    # '';

    # home.packages = with lib.pkgs; [
    #     zsh
    #     zsh-autosuggestions
    #     zsh-completions
    #     zsh-history-substring-search
    #     zsh-syntax-highlighting
    # ];
  };
}
