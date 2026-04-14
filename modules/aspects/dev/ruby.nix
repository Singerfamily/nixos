{
  dev.ruby = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.ruby ];
      };
  };
}
