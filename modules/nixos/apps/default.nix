{config, lib, ...}: {
  imports = [
    ./spotify.nix
    ./flatpak.nix
    ./steam.nix
  ];

  config.spotify.enable = lib.mkDefault true;
  config.flatpak.enable = lib.mkDefault true;
  config.steam.enable = lib.mkDefault false;
}