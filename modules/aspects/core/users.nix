{ den, ... }:
{
  # Base user management defaults
  den.default.nixos = { lib, ... }: {
    users.mutableUsers = lib.mkDefault false;

    # Enable zsh at system level so it appears in /etc/shells
    programs.zsh.enable = lib.mkDefault true;
  };
}
