{ den, ... }:
{
  # Shared power management defaults
  den.aspects.plasma-power = {
    includes = [ den.aspects.plasma ];
    homeManager =
      _:
      {
        programs.plasma.powerdevil = {
          AC = {
            autoSuspend.action = "nothing";
            dimDisplay.enable = false;
            powerButtonAction = "shutDown";
            turnOffDisplay.idleTimeout = 300;
          };
          battery = {
            autoSuspend.action = "nothing";
            dimDisplay.enable = true;
            powerButtonAction = "shutDown";
            turnOffDisplay.idleTimeout = 360;
          };
        };
      };
  };
}
