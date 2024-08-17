{lib, ...}: {
  hardware = {
    enableAllFirmware = lib.mkDefault true;
    enableRedistributableFirmware = lib.mkDefault true;
  };
}