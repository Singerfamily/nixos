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
    pipewire.enable = lib.mkForce false;
  };

  virtualisation = {
    docker.enable = true;
  };

  hardware = {
    pulseaudio = {
      enable = true;

      systemWide = true;
      tcp = {
        enable = true;
        anonymousClients.allowAll = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [ obs-studio ];
}
