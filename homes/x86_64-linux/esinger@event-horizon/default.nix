{ pkgs, ... }:
{
  snowfall = {
    dev = {
      dotnet.enable = true;
    };
  };

  home.packages = with pkgs; [
    deno

    jetbrains.datagrip
  ];
}
