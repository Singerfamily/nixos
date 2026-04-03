{ den, ... }:
{
  den.aspects.dev-js = {
    includes = [ den.aspects.dev ];
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
