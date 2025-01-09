{ lib, config, isWSL, ... }:
let
  cfg = config.services.pipewire;
in
{
  config = lib.mkIf (cfg.enable && !(isWSL)) {
    security.rtkit.enable = lib.mkForce true;
    hardware.pulseaudio.enable = lib.mkForce false;
    services.pipewire = {
      alsa = {
        enable = lib.mkForce true;
        support32Bit = lib.mkForce true;
      };
      pulse.enable = lib.mkForce true;
      jack.enable = lib.mkForce true;
    };
  };
}
