{ den, ... }:
{
  den.aspects.compat.nixos = { lib, ... }: {
    programs.nix-ld.enable = lib.mkDefault true;
    services.envfs.enable = lib.mkDefault true;
  };
}
