# INFO: NixOS Android Debug Bridge module.

{
  config,
  lib,
  ...
}:

with lib;
{
  options.snowfall.hardware.adb = {
    enable = mkOption {
      type = with types; bool;
      default = true;
    };
  };

  config = mkIf config.snowfall.hardware.adb.enable (
    let
      users = builtins.attrNames (config.home-manager.users or {});
    in
      {
        lib.
        programs.adb.enable = true;
        users.users = snowfall.mapUsersToGroup {
          group = "adbusers";
          users = users;
        };
      }
  );
}