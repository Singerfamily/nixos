{ den, ... }:
{
  den.aspects.tailscale.nixos =
    { lib, ... }:
    {
      services.tailscale = {
        enable = true;
        openFirewall = true;
        extraUpFlags = lib.mkDefault [
          "--ssh"
          "--reset"
        ];
      };
    };
}
