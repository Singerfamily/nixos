{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.desktop.plasma;
in
{
  options.desktop.plasma = {
    enable = lib.mkEnableOption "Enable Plasma Desktop";
  };

  config = lib.mkIf cfg.enable {
    services = {
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        autoNumlock = true;
      };
      desktopManager.plasma6.enable = true;
    };

    environment.systemPackages =
      with pkgs;
      [
        aha
        fwupd
        vulkan-tools
        wayland-utils
        pciutils
      ]
      ++ (with pkgs.kdePackages; [
        discover
        kaccounts-integration
        kaccounts-providers
        plasma-browser-integration
        plasma-disks
        kalk
        partitionmanager
        krdc
        (lib.mkIf config.services.hardware.bolt.enable plasma-thunderbolt)
      ]);
  };
}
