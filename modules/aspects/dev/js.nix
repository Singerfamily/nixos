{ den, ... }:
{
  den.aspects.dev-js = {
    includes = [ den.aspects.dev-common];
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          nodejs
          pnpm
        ];
      };
  };
}
