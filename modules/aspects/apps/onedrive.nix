{ den, ... }:
{
  den.aspects.onedrive.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.onedrive ];
    };
}
