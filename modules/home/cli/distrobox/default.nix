# INFO: distrobox Home-manager module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.cli.distrobox = {
    enable = mkOption {
      description = "Whether to enable `distrobox` - a tool to create and manage containerized development environments.";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf config.snowfall.cli.distrobox.enable {
    # snowfall.docker = {
    #   enable = lib.mkDefault true;
    #   implementation = lib.mkDefault "podman";
    # };
    home.packages = with pkgs; [
      distrobox
    ];
  };
}
