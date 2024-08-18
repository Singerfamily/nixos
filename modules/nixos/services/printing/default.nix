{ config, lib, pkgs, ... }: let
    cfg = config.services.printing;
in {
  config = lib.mkIf cfg.enable {
    services = {
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
    environment.systemPackages = [ pkgs.cups-filters ];
  };
}
