_:
{
  den.aspects.compat.nixos =
    _:
    {
      programs.nix-ld.enable = true;
      services.envfs.enable = true;
    };
}
