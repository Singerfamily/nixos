# INFO: bat Home-manager module.

{
  config,
  lib,
  ...
}:

with lib;
{
  options.snowfall.cli.bat = {
    enable = mkOption {
      description = "Whether to enable `bat`, the `cat(1)` clone with wings";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf config.snowfall.cli.bat.enable {
    programs.bat = {
      enable = true;
      config = {
        theme = mkDefault "base16";
        style = mkDefault "plain,grid,numbers,changes,snip";
      };
    };
  };
}
