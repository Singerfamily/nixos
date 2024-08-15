{lib, ...}: {
  imports = [
    ./drivers
    ./bluetooth.nix
  ];

  hardware.enableAllFirmware = true;
}