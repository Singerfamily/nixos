{config, lib, ...}: {
  imports = [
    ./spotify.nix
    ./steam.nix
  ];

  config.spotify.enable = lib.mkDefault true;
}