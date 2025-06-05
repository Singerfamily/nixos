{config, lib, ...}: {
  users.users = lib.mapAttrs
    (username: userCfg: userCfg // {
      hashedPasswordFile = config.sops.secrets."passwords/${username}".path;
    })
    { };
}