{ den, ... }:
{
  den.aspects.dev.python = {
    includes = [ den.aspects.dev ];
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          (python313.withPackages (ps: [
            ps.python-lsp-server
            ps.black
          ]))
          pyright
          ruff
          uv
        ];
      };
  };
}
