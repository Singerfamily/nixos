# INFO: Discord Home-manager module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.aeon.apps.steam = {
    enable = mkOption {
      type = with types; bool;
      default = false;
      description = "Whether to enable Steam";
    };

    remotePlay = mkOption {
      type = with types; bool;
      default = false;
      description = "Whether to enable Steam Remote Play";
    };
  };

  config =
    let
      inherit (config.aeon.apps.steam)
        enable
        remotePlay
        ;
    in
    mkIf enable {
      programs = {
        steam = {
          enable = true;
          remotePlay.openFirewall = remotePlay; # Open ports in the firewall for Steam Remote Play
          protontricks.enable = true;
        };
        gamemode.enable = true;
      };
    };
  # mkIf enable (mkMerge [
  #   (mkIf (app == "vencord") {
  #     home = {
  #       packages = with pkgs; [ vesktop ];
  #       persistence."${lib.aeon.persist}/home/${lib.aeon.user}" = {
  #         directories = [
  #           ".config/vesktop"
  #           ".config/VencordDesktop"
  #         ];
  #       };
  #     };
  #   })
  # ]);
}
