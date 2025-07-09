{ pkgs, lib, ... }:
let
  dotfiles = builtins.path {
    path = ./dotfiles;
    name = "dotfiles";
  };
in
{
  imports = [
    ./dotfiles/plasma.nix
  ];

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
      userName = "LeaderbotX400";
      userEmail = "34589843+LeaderbotX400@users.noreply.github.com";
    };

    vscode = {
      enable = true;
    };

    lazydocker.enable = true;

    onedrive = {
      enable = true;
    };

    nh = {
      enable = true;
      flake = "/home/esinger/projects/nixos";
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
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
      eza = {
        enable = true;
      };
    };

    user = {
      fullName = "Eric Singer";
      # email = "eric@singerfamily.ca";
    };

    dev = {
      dotnet.enable = true;
      js.enable = true;
      python.enable = true;
    };
    flatpak = {
      enable = true;
      packages = [
        "com.microsoft.Edge"
        "com.spotify.Client"
      ];
    };
  };

  home.packages = with pkgs; [
    jetbrains.datagrip
  ];
}
