{ lib, pkgs, ... }:
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
      userName = "clintsinger";
      userEmail = "clint@singerfamily.ca";
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
      flake = "/etc/nixos";
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
      atuin.enable = true;
      # eza = {
      #   enable = true;
      # };
    };

    games.minecraft.enable = true;

    user = {
      fullName = "Clint Singer";
    };

    dev = {
      dotnet.enable = true;
      js.enable = true;
    };

    flatpak = {
      enable = true;
      packages = [
        "com.microsoft.Edge"
        "com.spotify.Client"
        "org.libreoffice.LibreOffice"
      ];
    };
  };

  home.packages = with pkgs; [

    neovim
    speedtest-cli
    obs-studio
    talosctl

    jetbrains.rider
    jetbrains.datagrip
    jetbrains.ruby-mine
    jetbrains.rust-rover
    jetbrains.pycharm-professional
    jetbrains.goland

    android-studio
    dotnet
    dapr-cli
    python3
    python312Packages.pyudev
    ruby

    # embedded
    platformio-core
    (pkgs.python3.withPackages (ps: with ps; [ platformio ]))
    stlink
    openocd
    gdb
    cmake
    gcc
    stm32cubemx
    gcc-arm-embedded-13
  ];
}
