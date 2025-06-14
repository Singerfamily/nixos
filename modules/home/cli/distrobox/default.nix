# INFO: distrobox Home-manager module.

{
  config,
  lib,
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
    programs.distrobox = {
      enable = true;
    };
  };
}
