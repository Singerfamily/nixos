{config, lib, ...}: 
let
  cfg = config.bluetooth;
in {
  options.bluetooth = {
    enable = lib.mkEnableOption "Enable Bluetooth";
  };
  
  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true; # enables support for Bluetooth
      powerOnBoot = true; # powers up the default Bluetooth controller on boot
    };
  };
}