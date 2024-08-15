{ libx, hostname, ...}: {
  imports = [
    (libx.filesIn "./core")
    (libx.filesIn "./apps")
    (libx.filesIn "./desktop")
    (libx.filesIn "./services")
    (libx.filesIn "./hardware")
  ];

  config = libx.mkDefault {
    apps = {
      spotify.enable = true;
      steam.enable = true;
    };

    desktop = {
      plasma.enable = true;
    };

    networking.hostName = hostname;
  };
}