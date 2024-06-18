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
    ];
    hashedPasswordFile = config.sops.secrets.esinger-password.path;
  };

  sops.secrets.esinger-password = {
    sopsFile = ../../secrets.yaml;
    neededForUsers = true;
  };

  # Persist entire home
  environment.persistence = {
    "/persist".directories = ["/home/esinger"];
  };
}