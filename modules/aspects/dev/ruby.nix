{ den, ... }:
{
  den.aspects.dev-ruby = {
    includes = [ den.aspects.dev-common];
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.ruby ];
      };
  };
}
