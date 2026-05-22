_: {
  den.aspects.clint-pc.nixos =
    { pkgs, ... }:
    {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      boot.initrd.availableKernelModules = [
        "vmd"
        "xhci_pci"
        "ahci"
        "thunderbolt"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModprobeConfig = "options kvm_intel nested=1";

      # KASM workspace compatibility — relaxed SSH MACs.
      services.openssh.settings.Macs = [
        "hmac-sha2-256-etm@openssh.com"
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256"
        "hmac-sha2-512"
      ];

      environment.variables.LIBVIRT_DEFAULT_URI = "qemu:///system";

      environment.systemPackages = [ pkgs.lsof ];
    };
}
