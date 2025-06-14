{ ... }:
{
  home.stateVersion = "24.11";

  # home.file.".p10k.zsh".source = ./ + "p10k.zsh";

  programs = {
    git = {
      userName = "LeaderbotX400";
      userEmail = "34589843+LeaderbotX400@users.noreply.github.com";
    };

    vscode = {
      enable = true;
    }
  };

  snowfall = {
    cli = {
      atuin = {
        enable = true;
      };
    };
  };
}
