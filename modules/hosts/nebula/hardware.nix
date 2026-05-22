_: {
  den.aspects.nebula.nixos = _: {
    boot.loader.grub = {
      enable = true;
      efiSupport = false;
    };

    boot.initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "virtio_pci"
      "virtio_scsi"
      "sd_mod"
      "sr_mod"
    ];
    boot.kernelModules = [ "kvm-intel" ];
  };
}
