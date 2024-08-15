{pkgs, lib, config, ...}: 
let
  cfg = config.apps.spotify;
in {

  options.apps.spotify = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Spotify client";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      spotify
    ];

    # Spotify Local Discovery
    networking.firewall.allowedTCPPorts = [ 57621 ];

    # Google Cast
    networking.firewall.allowedUDPPorts = [ 5353 ];
  };
}