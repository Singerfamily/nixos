# INFO: `zoxide`, the smart cd command line tool, Home-manager module.

{
  config,
  lib,
  pkgs,
  ...
}:

# let
# inherit (config.aeon.theme)
#   ui
#   ;
# in

with lib;
{
  options.aeon.cli.zoxide = {
    enable = mkOption {
      description = "Whether to enable zoxide - the smart cd command line tool";
      type = with types; bool;
      default = true;
    };
  };

  config =
    let
      inherit (config.aeon.cli.zoxide)
        enable
        ;
    in
    mkIf enable {
      programs.zoxide = {
        enable = true;
        
        enableFishIntegration = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;

        options = [
          "--cmd cd"
        ];
      };
    };
}
