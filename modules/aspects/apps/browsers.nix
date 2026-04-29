_: {
  den.aspects.browsers.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        google-chrome
        firefox
        microsoft-edge
        chromium
      ];
    };
}
