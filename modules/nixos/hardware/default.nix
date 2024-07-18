{lib, ...}: {
  imports = [
    ./nvidia.nix
    ./bluetooth.nix
    ./power.nix
    ./printing.nix
  ];

  hardware.enableAllFirmware = true;
  nvidia.enable = lib.mkDefault true;
}