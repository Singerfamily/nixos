{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  drivers = {
    nvidia.enable = true;
    intel.enable = true;
  };

  programs = {
    firefox.enable = true;
    nix-ld.enable = true;
  };

  services = {
    # flatpak.enable = true;
  };

  virtualisation = {
    # qemu.enable = true;
    docker.enable = true;
    # podman.enable = true;
  };

  hardware = {
    pulseaudio = {
      systemWide = true;
    };
  };

  environment.systemPackages = with pkgs; [ obs-studio ];
}
