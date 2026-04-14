{
  dev.go = {
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
