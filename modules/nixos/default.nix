{ lib, ... }:
{
  desktop.plasma.enable = lib.mkDefault true;
  services.pipewire.enable = lib.mkDefault true;
}
