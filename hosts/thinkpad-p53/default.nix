{...}:
{
  imports = [ ./hardware-configuration.nix ];

  services = {
    hardware = {
      bolt.enable = true;
      bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
    };
  };
}
