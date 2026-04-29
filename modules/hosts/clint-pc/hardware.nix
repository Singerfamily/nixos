_:
{
  den.aspects.clint-pc.nixos = _: {
    boot.initrd.availableKernelModules = [
      "vmd"
      "xhci_pci"
      "ahci"
      "thunderbolt"
      "nvme"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModprobeConfig = "options kvm_intel nested=1";

    # NVIDIA PRIME bus IDs (consumed by the gpu-nvidia-prime aspect).
    den.gpuPrime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
