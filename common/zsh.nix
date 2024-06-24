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

    shellInit = "eval $(zoxide init --cmd cd zsh)";

    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";

    # plugins = with pkgs; [
    #   {
    #     file = "powerlevel10k.zsh-theme";
    #     name = "powerlevel10k";
    #     src = "${zsh-powerlevel10k}/share/zsh-powerlevel10k";
    #   }
    #   {
    #     file = "p10k.zsh";
    #     name = "powerlevel10k-config";
    #     src = ../configs/p10k-config; # Some directory containing your p10k.zsh file
    #   }
    # ];

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
