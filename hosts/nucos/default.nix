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
    udev = {
      packages = [ 
        pkgs.platformio-core
        pkgs.openocd
      ];
      extraRules = '' 
        # ENV{ID_VENDOR_ID}==\"046d\", ENV{ID_MODEL_ID}==\"0825\", ENV{PULSE_IGNORE}=\"1\"\n
      '';
    };
  };
  

  virtualisation = {
    docker.enable = true;
  };

  hardware = {
    pulseaudio = {
      enable = true;
      systemWide = true;
    };
  };

  environment.systemPackages = with pkgs; [ 
    obs-studio 
    stlink
  ];
}
