{ den, ... }:
{
  den.aspects.minecraft.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        jdk17
        prismlauncher
        packwiz
      ];
    };
}
