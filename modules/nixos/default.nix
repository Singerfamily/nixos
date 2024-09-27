{ libx, lib, ... }:
{
  imports =
    (libx.autoImport ./core)
    ++ (libx.autoImport ./apps)
    ++ (libx.autoImport ./desktop)
    ++ (libx.autoImport ./hardware)
    ++ (libx.autoImport ./services)
    ++ (libx.autoImport ./virtualization);

  desktop.plasma.enable = lib.mkDefault true;
  services.pipewire.enable = lib.mkDefault true;
}
