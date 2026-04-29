_:
{
  # Networking tools — applied to every user via den.default.homeManager.
  den.default.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        bandwhich
        doggo
        gping
        netdiscover
        nmap
        rustscan
        wakeonlan
      ];
    };
}
