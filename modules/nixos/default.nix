{lib, ...}: {
  imports = [
    ./global
    ./desktop/plasma.nix
    ./services

    ./hardware/nvidia.nix
  ];

  nvidia.enable = lib.mkDefault true;
  nvidia.prime = lib.mkDefault false;
}