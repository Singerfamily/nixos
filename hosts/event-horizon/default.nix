{ pkgs, ... }:
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
    # thunderbird.enable = true;
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
      users = [ "esinger" ];
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  environment = {
    variables = {
      NIXOS_OZONE_WL = "1";
    };

    systemPackages = with pkgs; [
      dbeaver-bin
      r2modman
      modrinth-app
      appimage-run
      wine

      # Dotnet
      jetbrains.rider
      jetbrains.datagrip
      dotnet-sdk_9

      # JS / TS
      nodejs
      nodePackages.pnpm
      deno
    ];
  };

  fileSystems."/mnt/media" = {
    device = "192.168.1.105:/mnt/stuff/media";
    fsType = "nfs";
  };
}
