_:
{
  den.aspects.docker = {
    nixos =
      _:
      {
        virtualisation.docker = {
          enable = true;
          autoPrune.enable = true;
          daemon.settings = {
            # Enable CDI (Container Device Interface) for GPU support
            features.cdi = true;
            live-restore = true;
          };
          rootless = {
            enable = true;
            setSocketVariable = true;
          };
        };
      };
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.lazydocker ];
      };
  };
}
