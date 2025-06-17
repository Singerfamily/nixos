{ lib, pkgs, ... }: let 
  dotfiles = builtins.path { path = ./dotfiles; name = "dotfiles"; };
in 
{
  imports = [
    ./dotfiles/plasma.nix
  ];

  home.stateVersion = "24.11";

  # home.file.".p10k.zsh".text = (builtins.readFile ./p10k.zsh);

  programs = {
    zsh.plugins = [
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource dotfiles;
        file = "p10k.zsh";
      }
    ];

    git = {
      enable = true;
      userName = "LeaderbotX400";
      userEmail = "34589843+LeaderbotX400@users.noreply.github.com";
    };

    vscode = {
      enable = true;
    };
  };

  snowfall = {
    apps = {
      discord.enable = true;
    };
    cli = {
      atuin = {
        enable = true;
      };
    };
  };
}
