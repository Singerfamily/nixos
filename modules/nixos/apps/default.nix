{config, lib, ...}: {
  imports = [
    ./spotify.nix
  ];

  config.spotify.enable = lib.mkDefault true;
}