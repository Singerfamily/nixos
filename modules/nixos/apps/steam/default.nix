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
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        protontricks.enable = true;
      };
      gamemode.enable = true;
    };

    networking.firewall = {
      allowedTCPPortRanges = [
        {
          from = 27015;
          to = 27030;
        }
        {
          from = 27036;
          to = 27037;
        }
      ];

      allowedUDPPorts = [
        4380
        27036
      ];

      allowedUDPPortRanges = [
        {
          from = 27000;
          to = 27031;
        }
      ];
    };

    environment.systemPackages = with pkgs; [
      protonup
      lutris
      steamtinkerlaunch
      winetricks
      protontricks
      wine
      wineWow64Packages.waylandFull
    ];
  };
}
