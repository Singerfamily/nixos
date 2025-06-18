{
  config,
  lib,
  pkgs,
  ...
}:
let
  users = builtins.attrNames (config.home-manager.users or { });
in
with lib;

{
  options.snowfall.cli = {
    enable = {
      type = types.bool;
      default = true;
      description = "CLI support for Snowfall users";
    };

    users = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = "List of users to enable CLI support for Snowfall.";
    };
  };

  config = {
    users.users = mkMerge (
      users
      |> map (
        username:
        let
          user = config.home-manager.users.${username};
          shell = user.snowfall.cli.shell;
          fullName = user.snowfall.user.fullName;
        in
        {
          ${username} = mkMerge [
            {
              # hashedPasswordFile = config.sops.secrets."passwords/${username}".path;
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWHFM4TnBtRI0YPjg3RNkh4axZ6fC/BrchvOh6r5aLj"
              ];

              hashedPassword = "$y$j9T$nCSl4qqjBNM3LSYw3NH1J0$T234Efg04y.oSX4I55ds3FdTmsYNCgqoib57Mwr5LI9";
              # description = username;
              extraGroups = [
                "video"
                "audio"
                "networkmanager"
                "builders"
              ];

              description = fullName;
            }

            (mkIf (shell.default == "bash") {
              shell = pkgs.bash;
            })

            (mkIf (shell.default == "zsh") {
              shell = pkgs.zsh;
              # programs.zsh.enable = true;
            })

            (mkIf (shell.default == "fish") {
              shell = pkgs.fish;
              # programs.fish.enable = true;
            })

            (mkIf (shell.default == "nushell") {
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
        |> any (
          username:
          let
            shell = config.home-manager.users.${username}.snowfall.cli.shell;
          in
          shell.default == "zsh"
        );

      fish.enable =
        users
        |> any (
          username:
          let
            shell = config.home-manager.users.${username}.snowfall.cli.shell;
          in
          shell.default == "fish"
        );
      # nushell.enable = any (
      #   username:
      #   let
      #     shell = config.home-manager.users.${username}.snowfall.cli.shell;
      #   in
      #   shell.default == "nushell"
      # ) users;
    };

    sops.secrets = mkMerge (
      map (username: {
        "passwords/${username}" = {
          neededForUsers = true;
        };
      }) users
    );
  };
}
