{ den, ... }:
{
  den.aspects.profile-laptop = {
    includes = with den.aspects; [
      gpu
    ];
  };
}
