{
  dev.js = {
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
