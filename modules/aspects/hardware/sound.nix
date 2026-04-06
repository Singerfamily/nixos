{ den, ... }:
{
  den.aspects.sound = {
    nixos =
      { lib, pkgs, ... }:
      {
        services.pipewire = {
          enable =  true;
          audio.enable =  true;
          alsa.enable =  true;
          alsa.support32Bit =  true;
          pulse.enable =  true;
          jack.enable =  true;
          wireplumber.enable =  true;
        };
        # Prevent HDA crackling
        boot.extraModprobeConfig =  "options snd_hda_intel power_save=0";
        security.rtkit.enable =  true;
        environment.systemPackages = [ pkgs.alsa-utils ];
      };
  };
}
