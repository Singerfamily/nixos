{ den, ... }:
{
  den.aspects.compat.nixos = { lib, ... }: {
    programs.nix-ld.enable =  true;
    services.envfs.enable =  true;
  };
}
