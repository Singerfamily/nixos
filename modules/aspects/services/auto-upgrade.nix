{ den, ... }:
{
  den.aspects.auto-upgrade.nixos = { lib, ... }: {
    system.autoUpgrade = {
      enable = lib.mkDefault true;
      dates = lib.mkDefault "0 4 * * 0";
      flake = lib.mkDefault "github:singerfamily/nixos";
      allowReboot = lib.mkDefault true;
    };
  };
}
