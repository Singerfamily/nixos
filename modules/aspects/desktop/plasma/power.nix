{ den, ... }:
{
  # Shared power management defaults
  den.aspects.plasma-power = {
    includes = [ den.aspects.plasma ];
    homeManager = { lib, ... }: {
      programs.plasma.powerdevil = {
        AC = {
          autoSuspend.action = lib.mkDefault "nothing";
          dimDisplay.enable = lib.mkDefault false;
          powerButtonAction = lib.mkDefault "shutDown";
          turnOffDisplay.idleTimeout = lib.mkDefault 300;
        };
        battery = {
          autoSuspend.action = lib.mkDefault "nothing";
          dimDisplay.enable = lib.mkDefault true;
          powerButtonAction = lib.mkDefault "shutDown";
          turnOffDisplay.idleTimeout = lib.mkDefault 360;
        };
      };
    };
  };
}
