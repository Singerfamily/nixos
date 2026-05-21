_:
{
  den.aspects.event-horizon.nixos =
    _:
    {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "sd_mod"
      ];
      boot.kernelModules = [ "kvm-amd" ];
      networking.hostId = "edc49e33";
    };
}
