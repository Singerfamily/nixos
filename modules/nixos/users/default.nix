{
  config,
  lib,
  pkgs,
  ...
}:
let
  # users = builtins.attrNames (config.snowfall.users or { });
  # inherit (config.snowfallorg) users;
  users = builtins.attrNames (
    (config.snowfallorg.users or { }) |> lib.filterAttrs (_: user: user.create)
  );
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
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIConMjdymJ8/2DplJAz/nsy2iqF/DHbWXH0yRm2jslQN"
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
              programs.bash.enable = true;
            })

            (mkIf (shell.default == "zsh") {
              shell = pkgs.zsh;
              programs.zsh.enable = true;
            })

            (mkIf (shell.default == "fish") {
              shell = pkgs.fish;
              programs.fish.enable = true;
            })

            (mkIf (shell.default == "nushell") {
              shell = pkgs.nushell;
              programs.nushell.enable = true;
            })
          ];
        }
      )
    );

    # Enable global programs if any user uses the shell
    # programs =
    #   let
    #     hasShell =
    #       shellName:
    #       any (username: config.home-manager.users.${username}.snowfall.cli.shell.default == shellName) users;
    #   in
    #   {
    #     zsh.enable = hasShell "zsh";
    #     fish.enable = hasShell "fish";
    #     # nushell.enable = hasShell "nushell";
    #   };

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
  };
}
