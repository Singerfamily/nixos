{ pkgs, username, ... }:
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
    ];
  };

  fileSystems."/mnt/media" = {
    device = "10.0.0.3:/mnt/stuff/media";
    fsType = "nfs";
  };

  services.udev.extraRules =
    let
      obsPath = "/home/${username}/obs";
    in
    ''
      ACTION=="add", SUBSYSTEM=="video4linux", KERNEL=="video0", RUN+="${pkgs.docker}/bin/docker compose -f ${obsPath}/docker-compose.yml up -d"
      ACTION=="remove", SUBSYSTEM=="video4linux", KERNEL=="video0", RUN+="${pkgs.docker}/bin/docker compose -f ${obsPath}/docker-compose.yml down"
    '';
}
