{ lib, pkgs, ... }: let 
  dotfiles = builtins.path { path = ./dotfiles; name = "dotfiles"; };
in 
{
  home.stateVersion = "24.11";

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
      userName = "clintsinger";
      userEmail = "clint@singerfamily.ca";
    };

    vscode = {
      enable = true;
    };
  };

  snowfall = {

    user = {
      fullName = "Clint Singer";
    };
  };
}
