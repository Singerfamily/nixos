{ ... }:
{
  den.aspects.docker = {
    nixos =
      { lib, pkgs, ... }:
      {
        virtualisation.docker = {
          enable = lib.mkDefault true;
          autoPrune.enable = lib.mkDefault true;
          daemon.settings = {
            # Enable CDI (Container Device Interface) for GPU support
            features.cdi = true;
          };
        };
        virtualisation.podman = {
          enable = lib.mkDefault true;
          defaultNetwork.settings.dns_enabled = lib.mkDefault true;
        };
        virtualisation.containers.enable = lib.mkDefault true;

        # Some large docker deployments (Elastic, Wazuh) need this
        boot.kernel.sysctl."vm.max_map_count" = lib.mkForce 262144;

        environment.systemPackages = with pkgs; [
          dive          # Explore each layer in a docker image
          docker-compose
          podman-compose
          podman-tui
        ];

      };
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.lazydocker ];
      };
  };
}
