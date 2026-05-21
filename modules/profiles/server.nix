{ den, ... }:
{
  den.aspects.profile-server = {
    includes = with den.aspects; [
    ];
  };
}
