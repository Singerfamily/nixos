{...}: {
  home.username = "esinger";
  home.homeDirectory = "/home/esinger";

  imports = [
    ./config/zsh.nix
    # ./config/hypr
  ];

  programs = {
    git = {
      enable = true;
      userName = "LeaderbotX400";
      userEmail = "eric@singerfamily.ca";
    };

  };

  home.stateVersion = "24.05";
}