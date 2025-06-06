{
  config,
  lib,
  pkgs,
  ...
}:
let
  users = builtins.attrNames (config.home-manager.users or { });
in
{
  config = {
    users.users = lib.mkMerge (
      users
      |> map (
        username:
        let
          shell = config.home-manager.users.${username}.snowfall.cli.shell;
        in
        {
          ${username} = lib.mkMerge [
            {
              hashedPasswordFile = config.sops.secrets."passwords/${username}".path;
              # description = username;
              extraGroups = [
                "video"
                "audio"
                "networkmanager"
                "tss"
                "builders"
              ];
            }

            lib.mkMerge
            [
              (lib.mkIf (shell.default == "bash") {
                shell = pkgs.bash;
              })

              (lib.mkIf (shell.default == "zsh") {
                shell = pkgs.zsh;
                programs.zsh.enable = true;
              })

              (lib.mkIf (shell.default == "fish") {
                shell = pkgs.fish;
                programs.fish.enable = true;
              })

              (lib.mkIf (shell.default == "nushell") {
                shell = pkgs.nushell;
              })
            ]
          ];
        }
      )

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
