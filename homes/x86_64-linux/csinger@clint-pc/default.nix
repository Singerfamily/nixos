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
      settings.user = {
        name = "clintsinger";
        email = "clint@singerfamily.ca";
      };
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
      python.enable = true;
      #ruby.enable = true;
      rust.enable = true;
    };

    flatpak = {
      enable = true;
      packages = [        
        "com.spotify.Client"
        "org.libreoffice.LibreOffice"
      ];
    };
  };

  home.sessionVariables = {
    OPENOCD_PATH = "${pkgs.openocd}";
    OPENOCD_SCRIPTS_PATH = "$OPENOCD_PATH/share/openocd/scripts";
  };

  home.packages = with pkgs; [

    gimp
    davinci-resolve
    slack

    neovim
    ookla-speedtest
    obs-studio
    talosctl
    inkscape-with-extensions
    vlc
    remmina

    jetbrains.rider
    jetbrains.datagrip
    #jetbrains.ruby-mine
    jetbrains.rust-rover
    jetbrains.pycharm
    jetbrains.goland

    android-studio
    dapr-cli
    # python3 — now provided by snowfall.dev.python module
    # python312Packages.pyudev
    gdb # included in gcc-arm-embedded-13
    cmake
    gcc
    gnumake

    # embedded
    # platformio-core
    # (pkgs.python3.withPackages (ps: with ps; [ platformio ]))
    stlink
    openocd
    # stm32cubemx
    #gcc-arm-embedded-13

    # winapps
    dialog
    freerdp
    iproute2
    libnotify
    nmap
    openssl
    nss.tools

    python3Packages.pytest
  ];
}
