{ den, ... }:
{
  den.aspects.sound = {
    nixos =
      { lib, pkgs, ... }:
      {
        services.pipewire = {
          enable = lib.mkDefault true;
          audio.enable = lib.mkDefault true;
          alsa.enable = lib.mkDefault true;
          alsa.support32Bit = lib.mkDefault true;
          pulse.enable = lib.mkDefault true;
          jack.enable = lib.mkDefault true;
          wireplumber.enable = lib.mkDefault true;
        };
        # Prevent HDA crackling
        boot.extraModprobeConfig = lib.mkDefault "options snd_hda_intel power_save=0";
        environment.systemPackages = [ pkgs.alsa-utils ];
      };
  };
}
