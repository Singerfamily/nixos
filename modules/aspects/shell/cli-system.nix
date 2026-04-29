_:
{
  # System inspection tools — applied to every user via den.default.homeManager.
  den.default.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        file
        pciutils
        usbutils
        smartmontools
        kondo
      ];
    };
}
