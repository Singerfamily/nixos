{pkgs, ...}: {

  options = {
    spotify = {
      enable = "Toggle Spotify client";
    };
  };

  config = lib.mkIf config.spotify.enable {
    environment.systemPackages = with pkgs; [
      spotify
    ];

    # Spotify Local Discovery
    networking.firewall.allowedTCPPorts = lib.mkIf config.spotify.discovery.local [ 57621 ];

    # Google Cast
    networking.firewall.allowedUDPPorts = lib.mkIf config.spotify.discovery.cast [ 5353 ];
  };
}