# INFO: steam Nixos module.

{
  config,
  lib,
  pkgs,
  ...
}:
let 
  cfg = config.snowfall.apps.steam;
in

with lib;
{
  options.snowfall.apps.steam = {
    enable = mkOption {
      description = "Whether to enable `steam` - a digital distribution platform for video games.";
      type = types.bool;
      default = false;
    };
    remotePlay = mkOption {
      description = "Whether to enable Steam Remote Play - a feature that allows you to stream games from your PC to other devices.";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf config.snowfall.apps.steam.enable {
    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = cfg.remotePlay; # Open ports in the firewall for Steam Remote Play
        protontricks.enable = true;
      };
      gamemode.enable = true;
    };

    environment.systemPackages = with pkgs; [
      protonup
      lutris
    ];
  };
}
