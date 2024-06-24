{ pkgs, lib, ... }: {
  imports = [
    ./nvidia.nix
    ./tailscale.nix
  ];
}