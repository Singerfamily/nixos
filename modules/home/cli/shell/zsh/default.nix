{config, lib, ...}: {
    config = lib.mkIf (config.snowfall.cli.shell.default == "zsh") {
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        initContent = ''
            cp ~/.zsh_history ~/.zsh_history.bak
            strings ~/.zsh_history.bak > ~/.zsh_history
            fc -R ~/.zsh_history

            export XDG_DATA_HOME="$HOME/.local/share"
            eval $(tailscale completion zsh)
        '';
        
        # home.packages = with lib.pkgs; [
        #     zsh
        #     zsh-autosuggestions
        #     zsh-completions
        #     zsh-history-substring-search
        #     zsh-syntax-highlighting
        # ];
    };
}