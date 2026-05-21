_: {
  den.quirks.firewall = {
    description = "Firewall port declarations. Both TCP and UDP ports are supported, and the aspect will flatten them into a single list for the NixOS firewall module. The aspect does not support port ranges or other more complex firewall rules; if those are needed, the aspect can be disabled and the user can configure the firewall directly in their NixOS configuration.";
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
