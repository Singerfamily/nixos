{ config, lib, ... }: let
    cfg = config.services.tailscale;
in {
  options.services.tailscale = {
    enable = lib.mkEnableOption {
      default = true;
      description = "Enable Tailscale VPN";
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = lib.mkDefault "client";
    };
    networking.firewall.allowedUDPPorts = [41641]; # Facilitate firewall punching
  };
}
