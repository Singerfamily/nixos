{ den, ... }:
{
  den.aspects.esinger = {
    includes = [
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")
    ];

    user = {
      name = "esinger";
      description = "Eric Singer";
    };
  };

  provides.event-horizon.homeManager =
    { pkgs, ... }:
    let
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Kay/contents/images_dark/5120x2880.png";
    in
    {

    };
}
