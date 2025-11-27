# INFO: NixOS PipeWire module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.sound = {
    enable = mkOption {
      description = "Whether to enable PipeWire sound system";
      type = with types; bool;
      default = (!(builtins.elem config.snowfall.core.type [ "server" ]));
    };
  };

  config = mkIf config.snowfall.sound.enable {
    security.rtkit.enable = true;

    # Disable audio power saving to prevent crackling
    boot.extraModprobeConfig = ''
      options snd_hda_intel power_save=0
    '';

    services.pipewire = {
      enable = true;
      pulse.enable = true;
      jack.enable = true;
      alsa.enable = true;
      wireplumber.enable = true;
    };

    # TODO: maybe add `pamixer` for easy volume control.
    environment.systemPackages = with pkgs; [ alsa-utils ];
  };
}
