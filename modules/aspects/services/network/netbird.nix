_: {
  den.aspects.netbird.nixos =
    { pkgs, ... }:
    {
      services.netbird.enable = true;
      services.resolved.enable = true;
      networking.firewall.trustedInterfaces = [ "wt0" ];
      systemd.services.netbird = {
        path = with pkgs; [ shadow ];
      };
    };
}
