{config, pkgs, lib, ...}: let
  cfg = config.desktop.plasma;
in {
  options.plasma = {
    enable = lib.mkEnableOption "Enable Plasma Desktop";
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm ={
      enable = true;
      wayland.enable = true;
      autoNumlock = true;
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
      kdePackages.plasma-disks
      kdePackages.kalk

      (lib.mkIf config.thunderbolt.enable kdePackages.plasma-thunderbolt)
    ];
  };
}
