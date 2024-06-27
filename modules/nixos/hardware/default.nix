{lib, ...}: {
  imports = [
    ./nvidia.nix
    ./bluetooth.nix
    ./power.nix
    ./printing.nix
  ];

  nvidia.enable = lib.mkDefault true;
  nvidia.prime = lib.mkDefault false;
}