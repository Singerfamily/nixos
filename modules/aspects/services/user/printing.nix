{ lib, ... }:
{
  den.aspects.printing.nixos =
    { config, lib, ... }:
    {
      options.den.printing = {
        enable = lib.mkEnableOption "CUPS printing";
        drivers = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "Printer drivers to register with CUPS.";
        };
      };
      config = lib.mkIf config.den.printing.enable {
        services.printing = {
          enable = true;
          drivers = config.den.printing.drivers;
        };
      };
    };
}
