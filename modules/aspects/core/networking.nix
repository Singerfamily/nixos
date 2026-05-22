_: {
  den.quirks.firewall = {
    description = "Firewall port declarations. Each entry may set `ports` (opened on both TCP and UDP), `tcpPorts` (TCP only), and/or `udpPorts` (UDP only); the aspect flattens these into the NixOS firewall lists. Port ranges and other complex rules are not supported; if those are needed, disable the aspect and configure networking.firewall directly in the NixOS configuration.";
  };

  den.aspects.networking = {
    nixos =
      { firewall, lib, ... }:
      {
        networking.networkmanager.enable = true;

        networking.firewall = {
          enable = true;
          allowedTCPPorts = lib.concatMap (f: (f.ports or [ ]) ++ (f.tcpPorts or [ ])) firewall;
          allowedUDPPorts = lib.concatMap (f: (f.ports or [ ]) ++ (f.udpPorts or [ ])) firewall;
        };
      };
  };
}
