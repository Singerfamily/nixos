{ den, ... }:
{
  den.aspects.profile-desktop = {
    includes = with den.aspects; [
      gpu
    ];
  };
}
