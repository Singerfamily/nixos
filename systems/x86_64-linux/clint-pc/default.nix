{
  lib,
  pkgs,
  config,
  ...
}:
{
  snowfall = {
    boot = {
      type = "uefi";
    };

    docker = {
      enable = true;
    };

    flatpak.enable = true;

    hardware = {
      bluetooth.enable = true;
      gpu = {
        intel = {
          enable = true;
          busID = "PCI:0:2:0";
        };
        nvidia = {
          enable = true;
          busID = "PCI:1:0:0";
        };
      };
    };

    qemu.enable = true;

    net.ssh = {
      enable = true;
      server = true; # Allow SSH'ing into this machine
    };   
  };

  # environment =    
  #   let
  #     dotnet = (with pkgs.dotnetCorePackages; combinePackages [ dotnet_9.sdk ]);
  #   in
  #   {
  #     sessionVariables = {
  #       DOTNET_PATH = "${dotnet}/bin/dotnet";
  #       DOTNET_ROOT = "${dotnet}/share/dotnet";
  #     };

  #     systemPackages = with pkgs; [
  #       dotnet        
  #     ];
  #   }; 


  # DANGER - Do not Modify Below!
  boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "ahci" "thunderbolt" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];


  fileSystems."/" =
    { device = "/dev/disk/by-uuid/5ce2ae63-604b-4e22-9923-4dc1f479ade6";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/1454-A232";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/9e72bc8a-7a48-4c4d-b180-6cd63a6aa1bd"; }
    ];

  fileSystems."/data" =
    { device = "/dev/disk/by-uuid/f54eca10-f82e-4531-a24f-af500a7e45bf";
      fsType = "ext4";
      # options = [ "subvol=log" "compress=zstd" "noatime" ];
      # neededForBoot = false;
    };

  environment = {
    variables = {
      LIBVIRT_DEFAULT_URI="qemu:///system";
    };
  };

  system.stateVersion = "24.11";
}
