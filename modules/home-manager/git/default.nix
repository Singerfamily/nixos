{ config, lib, ... }: let
    cfg = config.programs.git;
in {
  config = lib.mkIf cfg.enable {
    programs = {
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