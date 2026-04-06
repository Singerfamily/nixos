{ den, ... }:
{
  den.aspects.auto-upgrade.nixos = { lib, ... }: {
    system.autoUpgrade = {
      enable =  true;
      dates =  "0 4 * * 0";
      flake =  "github:singerfamily/nixos";
      allowReboot =  true;
    };
  };
}
