# INFO: User's shell NixOS module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  users = builtins.attrNames (config.home-manager.users or { });
in
{
  # NOTE: ${snowfall.user}'s default shell is a Home-manager option. This makes
  # adjustments to NixOS options based on ${snowfall.user}'s Home-manager option.

  # config = lib.mkMerge (
  #     map (username: {
  #       "passwords/${username}" = {
  #         neededForUsers = true;
  #       };
  #     }) users
  #   );

  config = lib.mkMerge (
    map (
      username:
      let
        shell = config.home-manager.users.${username}.snowfall.cli.shell;
      in
      lib.mkMerge [
        (lib.mkIf (shell.default == "bash") {
          users.users.${username}.shell = pkgs.bash;
        })

        (lib.mkIf (shell.default == "zsh") {
          users.users.${username}.shell = pkgs.zsh;
          programs.zsh.enable = true;
        })

        (lib.mkIf (shell.default == "fish") {
          users.users.${username}.shell = pkgs.fish;
          programs.fish.enable = true;
        })

        (lib.mkIf (shell.default == "nushell") {
          users.users.${username}.shell = pkgs.nushell;
        })
      ]
    ) users
  );
}
