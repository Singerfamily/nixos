{pkgs, lib, config, ...}: 
let
  cfg = config.spotify;
in {

  options.spotify = {
    enable = lib.mkEnableOption "Toggle Spotify client" true;
  };

  config = lib.mkIf config.spotify.enable {
    environment.systemPackages = with pkgs; [
      spotify
    ];

    # Spotify Local Discovery
    networking.firewall.allowedTCPPorts = [ 57621 ];

    # Google Cast
    networking.firewall.allowedUDPPorts = [ 5353 ];
  };
}