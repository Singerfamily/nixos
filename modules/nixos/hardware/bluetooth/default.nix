# INFO: NixOS Bluetooth module.

{
    config,
    lib,
    ...
}:

with lib; {
  options.snowfall.hardware.bluetooth = {
    # Whether to enable bluetooth support.
    enable = mkOption {
      type = with types; bool;
      default = false;
    };
  };

  config = mkIf config.snowfall.hardware.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;

      settings = {
        General = {
          Experimental = true;
          JustWorksRepairing = "always";
          MultiProfile = "multiple";
        };
      };
    };
  };
}