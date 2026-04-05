{ den, ... }:
{
  den.default.nixos = { lib, ... }: {
    services.locate.enable = lib.mkDefault true;
  };
}
