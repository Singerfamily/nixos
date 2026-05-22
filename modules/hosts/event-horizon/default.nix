{ den, ... }:
{
  den.hosts.x86_64-linux.event-horizon.users.eric = { };

  den.aspects.event-horizon.includes = with den.aspects; [
    profile-desktop
    profile-managed
    gpu-amd
    steam
    adb
  ];
}
