{ den, ... }:
{
  den.aspects.steam.nixos =
    { lib, pkgs, ... }:
    {
      programs.steam = {
        enable = lib.mkDefault true;
        remotePlay.openFirewall = lib.mkDefault true;
      };
      environment.systemPackages = with pkgs; [
        protontricks
        gamemode
        protonup-ng
      ];
    };
}
