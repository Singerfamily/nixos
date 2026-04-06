{ den, ... }:
{
  den.default.nixos = { lib, ... }: {
    services.locate.enable =  true;
  };
}
