{pkgs, ...}: let
  steam-with-pkgs = pkgs.steam.override {
    extraPkgs = pkgs:
      with pkgs; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
      ];
  };
in {
  users.users.esinger.packages = with pkgs; [
    firefox
    kdePackages.kate
    steam-with-pkgs
    gamescope
    protontricks
    lutris
    prismlauncher
  ];
}