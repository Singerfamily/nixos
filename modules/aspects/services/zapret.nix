{ den, ... }:
{
  # Zapret DPI bypass tool. Disabled by default — add to host includes to enable.
  den.aspects.zapret.nixos = { lib, ... }: {
    services.zapret = {
      enable = lib.mkDefault true;
      params = lib.mkDefault [
        "--dpi-desync=fake,disorder"
        "--dpi-desync-ttl=3"
      ];
      whitelist = lib.mkDefault [
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
