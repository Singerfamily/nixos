_:
{
  den.aspects.plymouth.nixos =
    _:
    {
      boot.plymouth.enable = true;
      boot.consoleLogLevel = 0;
      boot.initrd.verbose = false;
      boot.initrd.systemd.enable = true;
      boot.kernelParams = [
        "quiet"
        "splash"
        "loglevel=3"
        "systemd.show_status=auto"
        "udev.log_level=3"
        "rd.udev.log_level=3"
        "vt.global_cursor_default=0"
      ];
    };
}
