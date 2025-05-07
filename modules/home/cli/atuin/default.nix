# INFO: Atuin Home-manager module.
#
# ISSUE: Currently *really* slows down the shell when the history grows,
# should be solvable with the experimental `daemon` thing. However, that
# is still deemed unstable and I don't feel like fucking around with it
# just yet. Thus this is disabled by default for the time being.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.aeon.cli.atuin = {
    enable = mkOption {
      description = "Whether to enable Atuin, the magical shell history";
      type = types.bool;
      default = false;
    };

    sync = mkOption {
      description = "Whether to use Atuin's sync feature";
      type = types.bool;
      default = false;
    };

    host = mkOption {
      description = "Whether to host an Atuin server";
      type = types.bool;
      default = false;
    };
  };

  config = mkMerge [
    # Configure an Atuin client.
    (mkIf config.aeon.cli.atuin.enable {
      programs = {
        atuin = {
          enable = true;
          flags = [ "--disable-up-arrow" ];

          # INFO: https://docs.atuin.sh/configuration/config
          settings = {
            auto_sync = false;
            update_check = false;
            search_mode = "fuzzy";
            filter_mode = "host";
            secrets_filter = true;
            style = "compact";
            inline_height = 16;
          };

          enableZshIntegration = (config.aeon.cli.shell == "zsh");
          enableFishIntegration = (config.aeon.cli.shell == "fish");
          enableBashIntegration = (config.aeon.cli.shell == "bash");
          enableNushellIntegration = (config.aeon.cli.shell == "nushell");
        };
      };

      home.packages = with pkgs; [ atuin ];
    })

    # NOTE: Atuin is kinda wanky ATM, and I'm not using it at all,
    # so all of this stuff is gonna stay commented out until I figure out
    # whether or not I want to try using Atuin again.
    # (mkIf config.aeon.cli.atuin.sync {
    #     programs.atuin.settings = {
    #         auto_sync = true;
    #         sync_frequency = "10m";
    #         sync_address = "https://api.atuin.sh";
    #         filter_mode = "global";
    #         search_mode = "prefix";
    #     };
    # })
    #
    # (mkIf config.aeon.cli.atuin.host { })
  ];
}
