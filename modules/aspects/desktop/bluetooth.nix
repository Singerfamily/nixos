_:
{
  den.aspects.bluetooth = {
    nixos =
      _:
      {
        hardware.bluetooth.enable = true;
        hardware.bluetooth.powerOnBoot = true;
        services.blueman.enable = true;
      };
  };
}
