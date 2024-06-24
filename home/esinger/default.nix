{
  pkgs,
  lib,
  config,
  ...
}: {
  # imports = [./packages.nix];

  users.mutableUsers = false;
  users.users.esinger = {
    isNormalUser = true;
    shell = pkgs.zsh;
    name = "esinger";
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager" 
      "docker"
      "tss"
    ];
    hashedPassword = "$y$j9T$YphPlKG7g7gLEptn6BlZc0$dDzIl6DbbNc/2HYjzMnR6OaNnreOyEv5qyVSDZqRg10";
  };
}