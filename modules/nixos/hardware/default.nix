{lib, ...}: {
  imports = [
    ./nvidia.nix
    ./bluetooth.nix
    ./power.nix
    ./printing.nix
  ];

  hardware.enableAllFirmware = true;

  bluetooth.enable = lib.mkDefault true;
  nvidia.enable = lib.mkDefault true;
  nvidia.prime = lib.mkDefault true;
}