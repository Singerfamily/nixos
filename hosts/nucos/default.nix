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
        # udev rule for ST-LINK/V2 
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE:="0666", SYMLINK+="stlinkv2_%n"
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

  environment = {    
    systemPackages = with pkgs; [ 
      obs-studio 
      
      python3
      python312Packages.pyudev

      platformio-core
      (pkgs.python3.withPackages (ps: with ps; [ platformio ]))
      
      stlink
      openocd      

      gdb      
    ];

    variables = {      
      OPENOCD_PATH="${pkgs.openocd}";
      OPENOCD_SCRIPTS_PATH="$OPENOCD_PATH/share/openocd/scripts";
    };
  };
}
