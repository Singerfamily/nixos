{ den, ... }:
{
  # Base user management defaults
  den.default.nixos = { lib, ... }: {
    users.mutableUsers = lib.mkDefault false;
  };
}
