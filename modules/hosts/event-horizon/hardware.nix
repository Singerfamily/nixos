_: {
  den.aspects.event-horizon.nixos = _: {
    boot.loader.limine.enable = true;

    boot.initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "sd_mod"
    ];
    boot.kernelModules = [ "kvm-amd" ];
  };
}
