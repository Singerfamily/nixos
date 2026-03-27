{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.snowfall.ai = { };
  
  config = {
    home.packages = with pkgs; [
      mcp-nixos
    ];
  };
}
