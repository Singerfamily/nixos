{...}: {
  home.username = "esinger";
  home.homeDirectory = "/home/esinger";

  imports = [
    ./config/zsh
    ./config/hyprland.nix
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