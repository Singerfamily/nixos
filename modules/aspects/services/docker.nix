_: {
  den.aspects.docker = {
    nixos = _: {
      # Two daemons on purpose: the rootful system daemon backs the
      # oci-containers (the Authentik LDAP outpost runs on it), while
      # rootless gives the desktop user a daemon they own.
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
