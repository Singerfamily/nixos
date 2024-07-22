{...}: let
  cfg = config.thunderbolt;
in{
  options.thunderbolt = {
    enable = lib.mkEnableOption "Enable Thunderbolt support";
  };

  config = lib.mkIf cfg.enable {
    services.hardware.bolt.enable = true;
  };
}