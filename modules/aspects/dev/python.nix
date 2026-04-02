{ den, ... }:
{
  den.aspects.dev-python = {
    includes = [ den.aspects.dev ];
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          python313
          pyright
          ruff
          uv
        ];
      };
  };
}
