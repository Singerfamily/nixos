{ den, ... }:
{
  den.aspects.dev.go = {
    includes = [ den.aspects.dev ];
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          go
          gopls
          gotools
          go-tools
        ];
      };
  };
}
