{ den, inputs, ... }:
{
  den.hosts.x86_64-linux.event-horizon.users.esinger = { };

  den.aspects.event-horizon = {
    includes = with den.aspects; [
      profile-desktop
    ];

    nixos =
      { pkgs, ... }:
      {
        imports = [ inputs.disko.nixosModules.disko ];

        boot.loader.limine.enable = true;

        # Hardware
        boot.initrd.availableKernelModules = [
          "nvme"
          "xhci_pci"
          "ahci"
          "usbhid"
          "sd_mod"
        ];
        boot.kernelModules = [ "kvm-amd" ];
        networking.hostId = "edc49e33";

        # KDE Connect
        programs.kdeconnect.enable = true;
      };
  };
}
