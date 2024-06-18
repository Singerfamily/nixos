{ config, lib, pkgs, ... }: 

{
    environment.systemPackages = [
        pkgs.zoxide
        pkgs.fzf
    ];

    programs.zsh = {
        enable = true;
        # enableCompletion = true;
        # autosuggestion.enable = true;
        # syntaxHighlighting.enable = true;

        shellAliases = {
            ll = "ls -l";
            la = "ls -la";
            update = "sudo nixos-rebuild switch";
        };

        shellInit = [
            "eval '$(zoxide init zsh)'"
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