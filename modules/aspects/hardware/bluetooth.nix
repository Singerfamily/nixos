_:
{
  den.aspects.bluetooth = {
    nixos =
      _:
      {
        hardware.bluetooth = {
          enable = true;
          powerOnBoot = true;
          settings.General = {
            Experimental = true;
            JustWorksRepairing = "always";
            MultiProfile = "multiple";
            Enable = "Source,Sink,Media,Socket";
          };
        };
      };
  };
}
