_:
{
  den.aspects.distrobox.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.distrobox ];
    };
}
