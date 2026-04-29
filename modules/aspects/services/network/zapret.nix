_:
{
  # Zapret DPI bypass tool. Disabled by default — add to host includes to enable.
  den.aspects.zapret.nixos =
    _:
    {
      services.zapret = {
        enable = true;
        params = [
          "--dpi-desync=fake,disorder"
          "--dpi-desync-ttl=3"
        ];
        whitelist = [
          "discord.com"
          "element.io"
          "googlevideo.com"
          "matrix.org"
          "youtu.be"
          "youtube.com"
          "ytimg.com"
        ];
      };
    };
}
