{ pkgs, lib, ... }:
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

  desktop.plasma.enable = lib.mkForce false;

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
