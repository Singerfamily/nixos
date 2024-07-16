{lib, ...}: {
  imports = [
    ./fingerprint.nix
    ./tailscale.nix
    ./flatpak.nix
  ];

  config.flatpak.enable = lib.mkDefault true;
}