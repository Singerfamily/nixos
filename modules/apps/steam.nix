{pkgs, config, lib, ...}: 
let
  cfg = config.steam;
in {
  options = {
    steam = {
      enable = lib.mkEnableOption "Enable Steam";
      gamescopeSession = lib.mkEnableOption "Enable GameScope session";
      remotePlay = lib.mkEnableOption "Enable Steam Remote Play";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = cfg.remotePlay; # Open ports in the firewall for Steam Remote Play
    };

    environment.systemPackages = with pkgs; [
      protonup
    ];

    programs.gamemode.enable = true;
  };
}