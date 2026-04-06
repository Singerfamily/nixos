{ den, ... }:
{
  den.aspects.steam.nixos =
    { lib, pkgs, ... }:
    {
      programs.steam = {
        enable =  true;
        remotePlay.openFirewall =  true;
        protontricks.enable =  true;
      };
      programs.gamemode.enable =  true;
      environment.systemPackages = with pkgs; [
        protonup-ng
      ];
      # Steam networking
      networking.firewall = {
        allowedTCPPortRanges = [
          { from = 27015; to = 27030; }
          { from = 27036; to = 27037; }
        ];
        allowedUDPPorts = [ 4380 27036 ];
        allowedUDPPortRanges = [
          { from = 27000; to = 27031; }
        ];
      };
    };
}
