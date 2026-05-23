_: {
  den.aspects.clint.provides.clint-pc.homeManager =
    { pkgs, ... }:
    let
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Next/contents/images_dark/5120x2880.png";
    in
    {
      programs.plasma = {
        workspace.wallpaper = wallpaper;

        kscreenlocker = {
          autoLock = true;
          timeout = 10;
        };
      };
    };

  den.aspects.clint.provides.clint-pc.nixos = _: {
    users.users.clint.extraGroups = [ "libvirtd" ];
  };
}
