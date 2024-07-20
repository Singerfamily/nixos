{config, pkgs, lib, ...}: let
  cfg = config.plasma;
in {
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
}
