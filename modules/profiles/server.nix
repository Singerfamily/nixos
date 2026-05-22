{ den, ... }:
{
  # Headless role bundle. Currently minimal — server hosts (nebula) get the
  # bulk of their config from profile-managed; aspects land here as the
  # server fleet grows.
  den.aspects.profile-server = {
    includes = with den.aspects; [
      determinate
    ];
  };
}
