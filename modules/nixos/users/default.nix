{ config, lib, ... }:
let
  users = builtins.attrNames (config.home-manager.users or { });
in
{
  config = {
    users.users = lib.mkMerge (
      map (username: {
        ${username} = {
          hashedPasswordFile = config.sops.secrets."passwords/${username}".path;
          # description = username;
          extraGroups = [
            "video"
            "audio"
            "networkmanager"
            "tss"
            "builders"
          ];
        };
      }) users
    );

    sops.secrets = lib.mkMerge (
      map (username: {
        "passwords/${username}" = {
          neededForUsers = true;
        };
      }) users
    );
  };
}
