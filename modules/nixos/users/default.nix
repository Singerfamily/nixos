{ config, lib, ... }:
let
  normalUsers = config.users.users |> lib.filterAttrs (_: u: u.isNormalUser);
  patchUser = u: u // { description = lib.mkForce "test"; };
  patchedUsers = lib.mapAttrs (_: patchUser) normalUsers;
in
{
  # config.users.users = lib.mkMerge [
  #   # config.users.users
  #   patchedUsers
  # ];
}
