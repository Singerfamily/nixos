_:
{
  den.aspects.minecraft.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        graalvmPackages.graalvm-ce
        # prismlauncher # Bugged
        packwiz
      ];

      services.flatpak.packages = [
          "org.prismlauncher.PrismLauncher"
        ];
    };
}
