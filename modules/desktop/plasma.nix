{inputs, pkgs, ...}: let
  cfg = config.plasma;
in {

  options = {
    plasma = {
      enable = pkgs.lib.mkEnableOption "Enable KDE Plasma";
    };
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm ={
      enable = true;
      wayland.enable = true;
    };
    services.desktopManager.plasma6.enable = true;

    environment.systemPackages = with pkgs; [
      aha
      fwupd
      vulkan-tools
      wayland-utils
      pciutils
      discover

      kdePackages.kaccounts-integration
      kdePackages.kaccounts-providers
      kdePackages.plasma-browser-integration
    ];
  };
}