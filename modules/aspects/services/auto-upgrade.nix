_:
{
  den.aspects.auto-upgrade.nixos =
    _:
    {
      system.autoUpgrade = {
        enable = true;
        dates = "0 4 * * 0";
        flake = "github:singerfamily/nixos";
        allowReboot = true;
      };
    };
}
