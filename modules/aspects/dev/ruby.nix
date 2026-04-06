{ den, ... }:
{
  den.aspects.dev-ruby = {
    includes = [ den.aspects.dev ];
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.ruby ];
      };
  };
}
