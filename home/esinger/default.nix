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
    description = "Eric Singer";
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager" 
      "docker"
      "tss"
    ];
  };
}