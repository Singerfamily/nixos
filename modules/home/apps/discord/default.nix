# INFO: Discord Home-manager module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.apps.discord = {
    enable = mkOption {
      type = with types; bool;
      default = false;
      description = "Whether to enable Discord";
    };

    app = mkOption {
      type = with types; enum [ "vencord" ];
      default = "vencord";
      description = "What Discord client to use";
    };
  };

  config =
    let
      inherit (config.snowfall.apps.discord)
        enable
        app
        ;
    in
    mkIf enable (mkMerge [
      (mkIf (app == "vencord") {
        home = {
          packages = with pkgs; [ vesktop ];
          # persistence."${lib.snowfall.persist}/home/${lib.snowfall.user}" = {
          #   directories = [
          #     ".config/vesktop"
          #     ".config/VencordDesktop"
          #   ];
          # };
        };
      })
    ]);
}
