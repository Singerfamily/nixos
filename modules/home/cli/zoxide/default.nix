# INFO: `fzf`, a general-purpose command-line fuzzy finder (Home-manager module).

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.snowfall.theme)
    ui
    ;
in

with lib;
{
  options.snowfall.cli.zoxide = {
    enable = mkOption {
      description = "Whether to enable zoxide, a smarter cd command";
      type = with types; bool;
      default = true;
    };
  };

  config =
    let
      inherit (config.snowfall.cli.zoxide)
        enable
        ;
    in
    mkIf enable {
      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
        enableBashIntegration = true;
        enableZshIntegration = true;

        options = [
          "--cmd cd"
        ];
      };
    };
}
