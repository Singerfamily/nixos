_:
{
  den.aspects.event-horizon.nixos =
    { pkgs, ... }:
    {
      den.printing = {
        enable = true;
        drivers = [ pkgs.hplipWithPlugin ];
      };
      services.avahi.enable = false;
      programs.kdeconnect.enable = true;
    };
}
