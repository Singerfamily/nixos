{ config, pkgs, lib, ... }: 
let 
  cfg = config.secureboot;
in {
  options.secureboot = {
    enable = lib.mkEnableOption "Enable Secure Boot";
  };

  config = lib.mkIf cfg.enable {
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
    environment.systemPackages = with pkgs; [
      sbctl  # for key management
    ];
  };
}