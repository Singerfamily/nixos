{ den, ... }:
{
  den.aspects.dev-rust = {
    includes = [ den.aspects.dev ];
    homeManager =
      { pkgs, lib, ... }:
      {
        home.packages = with pkgs; [
          rustup
          cargo-nextest
          cargo-watch
          cargo-expand
          cargo-audit
          cargo-outdated
          cargo-binstall
          bacon
          sccache
        ];
      };
  };
}
