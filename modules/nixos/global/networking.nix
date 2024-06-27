{config, ...}: {
  networking.networkmanager.enable = true;
  networking.hostName = config.hostname;
}