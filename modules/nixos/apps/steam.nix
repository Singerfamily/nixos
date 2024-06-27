{pkgs, config, lib, ...}: {
  options = {
    steam = {
      enable = lib.mkEnableOption "Enable Steam";
      gamescopeSession = lib.mkEnableOption "Enable GameScope session";
      remotePlay = lib.mkEnableOption "Enable Steam Remote Play";
    };
  };

  config = lib.mkIf config.steam.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = lib.mkIf config.steam.remotePlay lib.mkDefault true; # Open ports in the firewall for Steam Remote Play
    };

    environment.systemPackages = with pkgs; [
      protonup
    ];

    programs.gamemode.enable = true;
  };
}