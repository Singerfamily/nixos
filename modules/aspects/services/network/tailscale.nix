_:
{
  den.aspects.tailscale.nixos =
    _:
    {
      services.tailscale = {
        enable = true;
        openFirewall = true;
        extraUpFlags = [
          "--ssh"
          "--reset"
        ];
      };
    };
}
