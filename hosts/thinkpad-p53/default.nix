{...}:
{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    lanzaboote.enable = true;
  };
  
  drivers = {
    nvidia.enable = true;
    intel.enable = true;
  };

  programs = {
    spotify.enable = true;
    steam.enable = true;
    thunderbird.enable = true;
    firefox.enable = true;
  };

  services = {
    flatpak.enable = true;
    onedrive.enable = true;
    fprintd.enable = true;

    hardware = {
      bolt.enable = true;
    };
  };

  virtualisation = {
    # qemu.enable = true;
    docker.enable = true;
  };

  hardware = {
    openrazer = {
      enable = true;
      users = ["esinger"]; 
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  security.pam.services.sddm.fprintAuth = true;
}
