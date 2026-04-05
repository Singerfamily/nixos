{ den, ... }:
{
  den.aspects.distrobox.homeManager = { pkgs, lib, ... }: {
    home.packages = [ pkgs.distrobox ];
  };
}
