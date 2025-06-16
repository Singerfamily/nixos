{ pkgs, ... }:
{
  snowfall = {
    dev = {
      dotnet.enable = true;
      js.enable = true;
    };
  };

  home.packages = with pkgs; [
    jetbrains.datagrip
  ];
}
