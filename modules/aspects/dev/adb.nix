_:
{
  den.aspects.adb = {
    nixos =
      { pkgs, ... }:
      {
        # systemd 258+ handles uaccess rules automatically; just ship the
        # userspace tools. No group membership required.
        environment.systemPackages = [ pkgs.android-tools ];
      };
  };
}
