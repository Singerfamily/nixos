_:
{
  # Wake-on-LAN firewall rules. Add to host includes to enable.
  den.aspects.wol.nixos =
    _:
    {
      networking.firewall = {
        allowedTCPPorts = [ 9 ];
        allowedUDPPorts = [ 9 ];
      };
    };
}
