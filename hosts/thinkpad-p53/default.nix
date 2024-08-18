{...}:
{
  imports = [ ./hardware-configuration.nix ];

  boot.secure.enable = true;

  services = {
    hardware = {
      bolt.enable = true;
    };
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
}
