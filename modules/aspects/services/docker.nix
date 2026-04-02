{ den, ... }:
{
  den.aspects.docker = {
    nixos =
      { lib, pkgs, ... }:
      {
        virtualisation.docker = {
          enable = lib.mkDefault true;
          autoPrune.enable = lib.mkDefault true;
          enableNvidia = lib.mkDefault false;
        };
        virtualisation.podman = {
          enable = lib.mkDefault true;
          defaultNetwork.settings.dns_enabled = lib.mkDefault true;
        };
        environment.systemPackages = [ pkgs.dive ];
        boot.kernel.sysctl."vm.max_map_count" = lib.mkDefault 262144;
      };
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.lazydocker ];
      };
  };
}
