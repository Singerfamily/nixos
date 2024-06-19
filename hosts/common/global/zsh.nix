{ config, lib, pkgs, ... }: 

{
    environment.systemPackages = with pkgs; [
        zoxide
        fzf
        zsh-autosuggestions
        zsh-autocomplete
    ];
    programs.zsh = {
        enable = true;

        shellAliases = {
            ll = "ls -l";
            la = "ls -la";
            update = "sudo nixos-rebuild switch --flake $HOME/nixos";
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