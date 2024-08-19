{...}:
{
  imports = [ ./hardware-configuration.nix ];
  
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
    qemu.enable = true;
    podman.enable = true;
    flatpak.enable = true;
    onedrive.enable = true;
    fprintd.enable = true;

    hardware = {
      bolt.enable = true;
    };
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
}
