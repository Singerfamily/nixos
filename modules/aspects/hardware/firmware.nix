_: {
  den.default.nixos =
    { config, ... }:
    {
      hardware.enableAllFirmware = true;
      hardware.cpu.amd.updateMicrocode = builtins.elem "kvm-amd" config.boot.kernelModules;
      hardware.cpu.intel.updateMicrocode = builtins.elem "kvm-intel" config.boot.kernelModules;
    };
}
