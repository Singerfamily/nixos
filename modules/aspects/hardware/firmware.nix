{ den, ... }:
{
  den.default.nixos = { lib, ... }: {
    hardware.enableRedistributableFirmware =  true;
    hardware.cpu.amd.updateMicrocode =  true;
    hardware.cpu.intel.updateMicrocode =  true;
  };
}
