{ den, ... }:
{
  den.aspects.plymouth.nixos = { lib, ... }: {
    boot.plymouth.enable = lib.mkDefault true;
    boot.consoleLogLevel = lib.mkDefault 0;
    boot.initrd.verbose = lib.mkDefault false;
    boot.initrd.systemd.enable = lib.mkDefault true;
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
