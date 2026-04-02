{ den, ... }:
{
  # Common dev tools included when any dev aspect is used
  den.aspects.dev.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        typos
        graphviz
      ];
    };
}
