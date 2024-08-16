{ config, pkgs, lib, inputs, ... }: 
let 
  cfg = config.boot.secure;
in {
  options.boot.secure = {
    enable = lib.mkEnableOption "Enable Secure Boot";
  };

  config = lib.mkIf cfg.enable {

    imports = [inputs.lanzaboote.nixosModules.lanzaboote];

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