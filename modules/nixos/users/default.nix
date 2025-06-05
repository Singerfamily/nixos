{
  config,
  lib,
  ...
}:

with lib;
{
  config = mkIf (config.home-manager.users |> builtins.hasAttr "${aeon.user}") {
    users.users = {
      ${aeon.user} = {
        # hashedPasswordFile = config.sops.secrets."passwords/${aeon.user}".path;
        hashedPassword = "$y$j9T$kiJLGzMAX1ZtE.FIjLX1J0$1pQSn6xkTNELfCPMpRuk5UFzSITnK1v7u4J85hs/2MA";
        # openssh.authorizedKeys.keys = aeon.pubKeys;
        extraGroups =
          [
            "wheel"
            "video"
            "audio"
            "input"
          ]
          ++ (
            [
              "networkmanager"
              "docker"
              "podman"
              "git"
              "libvirtd"
            ]
            |> builtins.filter (G: builtins.hasAttr G config.users.groups)
          );
      };
    };

    sops.secrets."passwords/${aeon.user}".neededForUsers = true;
  };
}
