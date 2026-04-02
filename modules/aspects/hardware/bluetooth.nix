{ den, ... }:
{
  den.aspects.bluetooth = {
    nixos = { lib, ... }: {
      hardware.bluetooth = {
        enable = lib.mkDefault true;
        powerOnBoot = lib.mkDefault true;
        settings.General = {
          Experimental = true;
          JustWorksRepairing = "always";
          MultiProfile = "multiple";
        };
      };
    };
  };
}
