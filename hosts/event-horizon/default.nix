{pkgs, ...}: {
  imports = [ ./hardware-configuration.nix ];

  boot.secure.enable = true;

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
  };

  hardware = {
    openrazer = {
      enable = true;
      users = ["esinger"]; 
    };
  };

  environment.systemPackages = [
    (pkgs.snapmaker-luban.overrideAttrs (oldAttrs: {
      version = "4.13.0";
      src = pkgs.fetchurl {
        url = "https://github.com/Snapmaker/Luban/releases/download/v4.13.0/snapmaker-luban-4.13.0-linux-x64.tar.gz";
        sha256 = "sha256-VNIuOsRTS5qsq4IK1G6NSidNNEgziHGTNGvDKwjPO70=";
      };
    }))
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "snapmaker-luban-4.13.0"
  ];
}
