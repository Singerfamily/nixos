{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [./packages.nix];

  users.mutableUsers = false;
  users.users.esinger = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager" 
      "docker"
    ];
    hashedPassword = "$y$j9T$YphPlKG7g7gLEptn6BlZc0$dDzIl6DbbNc/2HYjzMnR6OaNnreOyEv5qyVSDZqRg10";
  };
}