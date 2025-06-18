{ pkgs, lib, ... }:
{
  snowfall = {
    dev = {
      dotnet.enable = true;
      js.enable = true;
      python.enable = true;
    };
    flatpak = {
      enable = true;
      packages = [
        "com.microsoft.Edge"
        "com.spotify.Client"
      ];
    };
  };

  home.packages = with pkgs; [
    jetbrains.datagrip
  ];
}
