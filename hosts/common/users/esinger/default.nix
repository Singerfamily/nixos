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
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager" 
      "docker"
    ];
  };
}