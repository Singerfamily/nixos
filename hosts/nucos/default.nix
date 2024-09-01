{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  drivers = {
    nvidia.enable = true;
    intel.enable = true;
  };

  programs = {
    # spotify.enable = true;
    # steam.enable = true;
    # thunderbird.enable = true;
    firefox.enable = true;
    nix-ld.enable = true;
  };

  services = {
    flatpak.enable = true;
    # onedrive.enable = true;
    # davfs2.enable = true;
  };

  virtualisation = {
    qemu.enable = true;
    docker.enable = true;
    podman.enable = true;
  };

  environment.systemPackages = with pkgs; [ obs-studio ];
}
