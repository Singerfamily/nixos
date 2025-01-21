{ lib, ... }:
{
  desktop = {
    plasma.enable = lib.mkDefault true;
    # sway.enable = true;
  };
  services.pipewire.enable = lib.mkDefault true;
}
