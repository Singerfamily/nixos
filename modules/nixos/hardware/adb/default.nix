# INFO: NixOS Android Debug Bridge module.

{
    config,
    lib,
    ...
}:

with lib; {
  options.snowfall.hardware.adb = {
    # Whether to enable the Android Debug Bridge.
    enable = mkOption {
        type = with types; bool;
        default = false;
    };
  };

  config = mkIf config.snowfall.hardware.adb.enable {
      programs.adb.enable = true;
      users.users."esinger".extraGroups = [ "adbusers" ];
  };
}