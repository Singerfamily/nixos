{...}: {
  home.username = "esinger";
  home.homeDirectory = "/home/esinger";

  imports = [
    ./config/zsh.nix
    ./config/librewolf.nix
    # ./config/impermanence.nix
  ];

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
        git_protocol = "ssh";
        prompt = "enabled";
        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
      };
    };
  };

  home.stateVersion = "24.05";
}