{
  dev.python = {
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
