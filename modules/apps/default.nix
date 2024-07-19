{config, lib, ...}: {
  imports = [
    ./spotify.nix
    ./steam.nix
    ./firefox.nix
  ];

  config.spotify.enable = lib.mkDefault true;
}