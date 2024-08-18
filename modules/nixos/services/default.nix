{lib, libx, ...}: {
  imports = [ (libx.autoImports ./.) ];
  
  hardware = {
    enableAllFirmware = lib.mkDefault true;
    enableRedistributableFirmware = lib.mkDefault true;
  };
}