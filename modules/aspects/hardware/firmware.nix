_:
{
  den.default.nixos =
    _:
    {
      hardware.enableRedistributableFirmware = true;
      hardware.cpu.amd.updateMicrocode = true;
      hardware.cpu.intel.updateMicrocode = true;
    };
}
