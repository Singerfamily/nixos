{config, lib, ...}: {
  options = {
    plasma.enable = lib.mkEnableOption "Enable KDE Plasma Desktop Environment";
  };

  config = lib.mkIf config.plasma.enable {
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    services.xserver = {
      layout = "us";
      xkbVariant = "";
    };
  };
}