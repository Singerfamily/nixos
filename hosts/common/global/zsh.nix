{ config, lib, pkgs, ... }: 

{
    environment.systemPackages = with pkgs; [
        zoxide
        fzf
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

        shellInit = "eval '$(zoxide init zsh)'";

        ohMyZsh = {
         enable = true;
         theme = "romkatv/powerlevel10k";
         plugins = [
           "git"
           "npm"
           "history"
           "node"
           "zsh-users/zsh-autosuggestions"
           "marlonrichert/zsh-autocomplete"
         ];
      };

    };
}