{
  config,
  lib,
  pkgs,
  ...
}:
let
  # users = builtins.attrNames (config.snowfall.users or { });
  inherit (config.snowfall) users;
in
with lib;

{
  options.snowfall = {
    cli = {
      enable = {
        type = types.bool;
        default = true;
        description = "CLI support for Snowfall users";
      };
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
              hashedPasswordFile = config.sops.secrets."${username}/password".path;
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWHFM4TnBtRI0YPjg3RNkh4axZ6fC/BrchvOh6r5aLj"
              ];

              extraGroups = mkMerge [
                [
                  "networkmanager"
                  "builders"
                  "kvm"
                  "libvirtd"
                ]

                (mkIf config.services.pipewire.enable [
                  "audio"
                  "video"
                ])
              ];

              description = fullName;
            }

            (mkIf (shell.default == "bash") {
              shell = pkgs.bash;
            })

            (mkIf (shell.default == "zsh") {
              shell = pkgs.zsh;
            })

            (mkIf (shell.default == "fish") {
              shell = pkgs.fish;
            })

            (mkIf (shell.default == "nushell") {
              shell = pkgs.nushell;
            })
          ];
        }
      )
    );

    # Enable global programs if any user uses the shell
    programs =
      let
        hasShell =
          shellName:
          any (username: config.home-manager.users.${username}.snowfall.cli.shell.default == shellName) users;
      in
      {
        zsh.enable = hasShell "zsh";
        fish.enable = hasShell "fish";
        # nushell.enable = hasShell "nushell";
      };

    sops.secrets = mkMerge (
      users
      |> map (username: {
        "${username}/password" = {
          key = "password";
          neededForUsers = true;
          sopsFile = ../../../secrets/users + "/${username}.yaml"; # Needed since user passwords are stored in a separate sops file per user instead of the host one.
        };
      })
    );

    # sops.secrets = mkMerge (
    #   users
    #   |> map (username: {
    #     "passwords/${username}" = {
    #       neededForUsers = true;
    #     };
    #   })
    # );
  };
}
