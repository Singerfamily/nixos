{ config, lib, pkgs, ... }: 

{
    environment.systemPackages = with pkgs; [
        fzf
    ];

    programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
    };

    programs.fzf = {
        enable = true;
        enableZshIntegration = true;
    };

    environment.systemPackages = with pkgs; [
        zsh-autosuggestions
        zsh-autocomplete
    ];

    programs.zsh = {
        enable = true;

        shellAliases = {
            ll = "ls -l";
            la = "ls -la";
            update = "sudo nixos-rebuild switch";
        };

        shellInit = "eval '$(zoxide init zsh)'";

        promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";

        ohMyZsh = {
         enable = true;
         plugins = [
           "git"
           "npm"
           "history"
           "node"
         ];
      };

    };
}