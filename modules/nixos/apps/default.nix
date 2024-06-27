{config, lib, ...}: {
  imports = [
    ./spotify.nix
    ./steam.nix
  ];

  config.spotify.enable = lib.mkDefault true;
  config.steam.enable = lib.mkDefault false;
}