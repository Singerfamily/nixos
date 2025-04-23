{ ... }:
{
  programs = {
    git = {
      enable = true;
      userName = "LeaderbotX400";
      userEmail = "34589843+LeaderbotX400@users.noreply.github.com";
    };

    zsh.enable = true;
    zoxide.enable = true;
    fzf.enable = true;

    atuin = {
      enable = true;

      settings = {
        auto_sync = true;
        sync_frequency = "5m";
        sync_address = "https://api.atuin.sh";
        search_mode = "fuzzy";
      };

      enableZshIntegration = true;
    };
  };
}
