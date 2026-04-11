{ den, ... }:
{
  # Common dev tools included when any dev aspect is used
  den.aspects.dev-common.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        typos
        graphviz
      ];
    };
}
