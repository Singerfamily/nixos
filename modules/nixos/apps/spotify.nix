{pkgs, lib, config, ...}: {

  options = {
    spotify = {
      enable = lib.mkEnableOption "Toggle Spotify client";
    };
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