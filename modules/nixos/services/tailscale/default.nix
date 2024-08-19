{ lib, ... }: {
  services = {
    tailscale = {
      enable = true;
      useRoutingFeatures = lib.mkDefault "client";
    };
    davfs2.enable = true;
  };
  networking.firewall.allowedUDPPorts = [41641]; # Facilitate firewall punching
}
