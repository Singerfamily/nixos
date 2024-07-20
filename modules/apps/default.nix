{config, lib, ...}: {
  imports = [
    ./spotify.nix
    ./steam.nix
    ./firefox.nix
  ];
}