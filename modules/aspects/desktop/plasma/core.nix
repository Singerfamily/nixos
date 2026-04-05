{ den, inputs, ... }:
{
  # Plasma desktop - NixOS-level setup (SDDM, packages, portals)
  den.aspects.plasma = {
    nixos =
      { lib, pkgs, ... }:
      {
        services.desktopManager.plasma6.enable = lib.mkDefault true;
        services.displayManager.sddm = {
          enable = lib.mkDefault true;
          wayland.enable = lib.mkDefault true;
          autoNumlock = lib.mkDefault true;
        };
        xdg.portal = {
          enable = lib.mkDefault true;
          extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
          config.common.default = lib.mkDefault "kde";
        };
        environment.systemPackages =
          (with pkgs.kdePackages; [
            discover
            kaccounts-integration
            kaccounts-providers
            plasma-browser-integration
            plasma-disks
            kalk
            partitionmanager
            kpipewire
            sddm-kcm
            krdc
            krfb
            krdp
          ])
          ++ (with pkgs; [
            aha
            fwupd
            vulkan-tools
            wayland-utils
            freerdp
          ]);
        networking.firewall.allowedTCPPorts = [
          3388 # KRDP
          3389 # RDP
        ];
      };

    # Home-manager: import plasma-manager and set shared defaults
    homeManager = { lib, pkgs, ... }: {
      imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

      home.packages = with pkgs; [
        kde-rounded-corners
        kdotool
      ];

      programs.plasma = {
        enable = lib.mkDefault true;
        overrideConfig = lib.mkDefault true;

        krunner.activateWhenTypingOnDesktop = lib.mkDefault false;

        session = {
          general.askForConfirmationOnLogout = lib.mkDefault false;
          sessionRestore.restoreOpenApplicationsOnLogin = lib.mkDefault "startWithEmptySession";
        };

        workspace = {
          enableMiddleClickPaste = lib.mkDefault false;
          clickItemTo = lib.mkDefault "select";
          colorScheme = lib.mkDefault "BreezeDark";
          splashScreen.engine = lib.mkDefault "none";
          splashScreen.theme = lib.mkDefault "none";
          tooltipDelay = lib.mkDefault 1;
        };

        configFile = {
          klipperrc.General.MaxClipItems = lib.mkDefault 1000;
          kiorc.Confirmations.ConfirmDelete = lib.mkDefault false;
          spectaclerc = {
            Annotations.annotationToolType = lib.mkDefault 8;
            General = {
              launchAction = lib.mkDefault "DoNotTakeScreenshot";
              showCaptureInstructions = lib.mkDefault false;
              showMagnifier = lib.mkDefault "ShowMagnifierAlways";
            };
            ImageSave.imageCompressionQuality = lib.mkDefault 100;
          };
        };

        dataFile = {
          "dolphin/view_properties/global/.directory"."Dolphin"."ViewMode" = lib.mkDefault 1;
          "dolphin/view_properties/global/.directory"."Settings"."HiddenFilesShown" = lib.mkDefault true;
        };
      };
    };
  };
}
