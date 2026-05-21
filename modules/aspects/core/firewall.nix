{ den, ... }:
{
  den.quirks.firewall = {
    description = "Firewall port declarations";
  };

  den.aspects.networking = {
    nixos =
      { firewall, lib, ... }:
      {
        networking.networkmanager.enable = true;

        networking.firewall = {
          enable = true;
          allowedTCPPorts = lib.concatMap (f: f.ports or [ ]) firewall;
          allowedUDPPorts = lib.concatMap (f: f.ports or [ ]) firewall;
        };
      };
  };
}
