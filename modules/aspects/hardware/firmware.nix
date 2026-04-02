{ den, ... }:
{
  den.default.nixos = { lib, ... }: {
    hardware.enableRedistributableFirmware = lib.mkDefault true;
    hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
    hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  };
}
