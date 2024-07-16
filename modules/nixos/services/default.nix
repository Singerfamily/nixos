{lib, ...}: {
  imports = [
    ./fingerprint.nix
    ./tailscale.nix
    ./flatpak.nix
    ./rdp.nix
  ];

  config.flatpak.enable = lib.mkDefault true;
}