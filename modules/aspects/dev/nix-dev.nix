{ den, ... }:
{
  den.aspects.dev-nix.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nixd
        nixfmt-rfc-style
        statix
        deadnix
      ];
    };
}
