{ config, pkgs, lib, username, ... }: 
let
  cfg = config.services.podman;
in {
  options.services.docker = {
    enable = lib.mkEnableOption "Enable Docker";
  };

  config = lib.mkIf cfg.enable {
    hardware.nvidia-container-toolkit.enable = true;

    users.users.${username}.extraGroups = [
      "docker"
    ];
    virtualisation = {
      docker = {
        enable = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
        autoPrune = true;
        enableNvidia = true;
      };
    };

    # Useful other development tools
    environment.systemPackages = with pkgs; [
      distrobox
      dive            # look into docker image layers
      podman-tui      # status of containers in the terminal
      podman-compose # start group of containers for dev
    ];
  };
}