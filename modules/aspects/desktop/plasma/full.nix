{ den, ... }:
{
  # Convenience: include all shared plasma aspects at once
  # Usage: den.aspects.<user>.includes = [ den.aspects.plasma-full ];
  den.aspects.plasma-full = {
    includes = [
      den.aspects.plasma
      den.aspects.plasma-keybinds
      den.aspects.plasma-kwin
      den.aspects.plasma-power
    ];
  };
}
