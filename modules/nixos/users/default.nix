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

  options.snowfall.cli = {
    enable = lib.mkEnableOption "CLI support for Snowfall users";

    users = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "List of users to enable CLI support for Snowfall.";
    };
  };

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
            (lib.mkIf (shell.default == "bash") {
              shell = pkgs.bash;
            })

            (lib.mkIf (shell.default == "zsh") {
              shell = pkgs.zsh;
              # programs.zsh.enable = true;
            })

            (lib.mkIf (shell.default == "fish") {
              shell = pkgs.fish;
              # programs.fish.enable = true;
            })

            (lib.mkIf (shell.default == "nushell") {
              shell = pkgs.nushell;
            })
          ];
        }
      )
    );

    # Enable global programs if any user uses the shell
    programs = {
      zsh.enable =
        users
        |> lib.any (
          username:
          let
            shell = config.home-manager.users.${username}.snowfall.cli.shell;
          in
          shell.default == "zsh"
        );

      fish.enable =
        users
        |> lib.any (
          username:
          let
            shell = config.home-manager.users.${username}.snowfall.cli.shell;
          in
          shell.default == "fish"
        );
      # nushell.enable = lib.any (
      #   username:
      #   let
      #     shell = config.home-manager.users.${username}.snowfall.cli.shell;
      #   in
      #   shell.default == "nushell"
      # ) users;
    };

    sops.secrets = lib.mkMerge (
      map (username: {
        "passwords/${username}" = {
          neededForUsers = true;
        };
      }) users
    );
  };
}
