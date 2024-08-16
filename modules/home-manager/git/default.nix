{ config, lib, ... }: let
    cfg = config.module.git;
in {
  options.module.git = {
    enable = lib.mkEnableOption "Enable Git";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      git = {
        enable = true;
        userName = "LeaderbotX400";
        userEmail = "eric@singerfamily.ca";
      };

      gh = {
        enable = true;

        gitCredentialHelper.enable = true;

        settings = {
          git_protocol = "https";
          prompt = "enabled";
          aliases = {
            co = "pr checkout";
            pv = "pr view";
          };
        };
      };
    };
  };
}