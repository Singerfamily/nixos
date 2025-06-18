# INFO: plasma Home-manager module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  # HACK: Here, because importing in flake.nix does not work.
  # imports = with inputs; [ plasma.homeManagerModules.default ];

  options.snowfall.desktop.plasma = {
    enable = mkOption {
      description = "Whether to enable and configure plasma";
      type = with types; bool;
      default = true;
    };
  };

  config =
    let
      inherit (config.snowfall.desktop.plasma)
        enable
        ;
    in
    mkIf enable {
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
          freerdp
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
          krfb
          krdp
        ]);
    };
}