{ config, lib, pkgs, ... }: let
    cfg = config.services.printing;
in {
  options.services.printing = {
    enable = lib.mkEnableOption "Enable Printing";
  };

  config = lib.mkIf cfg.enable {
    services = {
      printing.enable = true;
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
    environment.systemPackages = [ pkgs.cups-filters ];
  };
}
