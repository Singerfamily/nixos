# NOTE: 

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.cli.zoxide.enable = mkOption {
    description = "Whether to enable zoxide - a smarter cd command";
    type = with types; bool;
    default = true;
  };

  config =
    let
      inherit (config.snowfall.cli.zoxide)
        enable
        ;
    in
    mkIf enable {
      home = {
        programs.zoxide = {
            enableZshIntegration = true;
            enableBashIntegration = true;
            enableFishIntegration = true;
            options = [
                "--cmd cd"
            ];
        };

      };
    };
}
