{ ... }: {
  imports = [
    ./nvidia.nix
    ./tailscale.nix
    ./fingerprint.nix
  ];
}