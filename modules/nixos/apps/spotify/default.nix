# INFO: Spotify Nixos module.

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.snowfall.apps.spotify;
in

with lib;
{
  options.snowfall.apps.spotify = {
    enable = mkOption {
      description = "Whether to enable `spotify` - a digital music service that gives you access to millions of songs.";
      type = types.bool;
      default = false;
    };
    openFirewall = mkOption {
      description = "Whether to open the firewall for Spotify Local Discovery and Google Cast.";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf config.snowfall.apps.spotify.enable {
    environment.systemPackages = with pkgs; [
      spotify
    ];

    networking.firewall = mkIf cfg.openFirewall {
      # Spotify Local Discovery
      allowedTCPPorts = [ 57621 ];

      # Google Cast
      allowedUDPPorts = [ 5353 ];
    };
  };
}
