{ lib, pkgs, ... }:
let
  dotfiles = builtins.path {
    path = ./dotfiles;
    name = "dotfiles";
  };
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
      #ruby.enable = true;
      rust.enable = true;
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

  home.sessionVariables = {    
    OPENOCD_PATH = "${pkgs.openocd}";
    OPENOCD_SCRIPTS_PATH = "$OPENOCD_PATH/share/openocd/scripts";
  };

  home.packages = with pkgs; [

    neovim
    ookla-speedtest
    obs-studio
    talosctl
    inkscape-with-extensions

    jetbrains.rider
    jetbrains.datagrip
    #jetbrains.ruby-mine
    jetbrains.rust-rover
    jetbrains.pycharm-professional
    jetbrains.goland

    android-studio    
    dapr-cli
    # python3
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
    curl
    freerdp
    git
    iproute2
    libnotify
    nmap
    openssl
  ];
}
