{lib, ...}: {
  imports = [
    ./drivers/nvidia.nix
    ./drivers/intel.nix
    ./bluetooth.nix
    ./power.nix
    ./printing.nix
  ];

  hardware.enableAllFirmware = true;
}