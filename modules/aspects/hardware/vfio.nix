_:
{
  # VFIO PCI passthrough for GPU/device passthrough to VMs.
  # To use: add den.aspects.vfio to host includes, then set
  # pciIDs in the host's nixos config via boot.kernelParams.
  den.aspects.vfio.nixos =
    _:
    {
      boot.kernelParams = [ "intel_iommu=on" ];
      boot.initrd.kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
      ];
      hardware.graphics.enable = true;
      virtualisation.spiceUSBRedirection.enable = true;
    };
}
