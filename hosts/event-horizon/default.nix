{pkgs, ...}: {
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
    nix-ld.enable = true;

    # snapmaker-luban.enable = true;
  };

  services = {
    flatpak.enable = true;
    onedrive.enable = true;
    davfs2.enable = true;
  };

  virtualisation = {
    qemu.enable = true;
    docker.enable = true;
    podman.enable = true;
  };

  hardware = {
    openrazer = {
      enable = true;
      users = ["esinger"]; 
    };
  };

  fileSystems."/mnt/media" = {
    device = "10.0.0.3:/mnt/stuff/media";
    fsType = "nfs";
  };

  # powerManagement.powerDownCommands = ''
  #   if (grep "GPP0.*enabled" /proc/acpi/wakeup >/dev/null); then
  #       echo GPP0 | sudo tee /proc/acpi/wakeup
  #   fi
  # '';
}
