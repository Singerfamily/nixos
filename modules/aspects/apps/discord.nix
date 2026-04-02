{ den, ... }:
{
  den.aspects.discord.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.vesktop ];
    };
}
