_: {
  den.aspects.media-tools.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        imagemagick
        ffmpeg
        pngquant
        optipng
        (python3.withPackages (ps: [ ps.pillow ]))
      ];
    };
}
