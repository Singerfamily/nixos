{lib, ...}: {
  imports = [
    ./nvidia.nix
    ./intel.nix
    ./bluetooth.nix
  ];

  hardware.enableAllFirmware = true;
}