_:
{
  den.aspects.atuin.homeManager =
    _:
    {
      programs.atuin = {
        enable = true;
        flags = [ "--disable-up-arrow" ];
        settings = {
          auto_sync = false;
          update_check = false;
          search_mode = "fuzzy";
          filter_mode = "host";
          secrets_filter = true;
          style = "compact";
          inline_height = 16;
        };
        enableZshIntegration = true;
        enableBashIntegration = true;
      };
    };
}
