{ config, lib, pkgs, ... }: 

{
    environment.systemPackages = [
        zoxide
        fzf
    ];

    programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        shellAliases = {
            ll = "ls -l";
            la = "ls -la";
            update = "sudo nixos-rebuild switch";
        };
        history = {
            size = 10000;
            path = "${config.xdg.dataHome}/zsh/history";
        };

        shellInit = [
            "eval(zoxide init --cmd cd zsh)"
        ];

        ohMyZsh = {
         enable = true;
         theme = "robbyrussell";
         plugins = [
           "git"
           "npm"
           "history"
           "node"
         ];
      };

    };
}