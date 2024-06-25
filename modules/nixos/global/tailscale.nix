{lib, ...}: {
  services.tailscale = {
    enable = lib.mkDefault true;
    useRoutingFeatures = lib.mkDefault "client";
  };
  networking.firewall.allowedUDPPorts = [41641]; # Facilitate firewall punching
}