{ inputs, ... }:
{
  # Plasma desktop - NixOS-level setup (SDDM, packages, portals)
  den.aspects.plasma = {
    nixos =
      { pkgs, ... }:
      {
        services.desktopManager.plasma6.enable = true;
        services.displayManager.sddm = {
          enable = true;
          wayland.enable = true;
          autoNumlock = true;
        };

        xdg.portal = {
          enable = true;
          extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
          config.common.default = "kde";
        };

        environment.systemPackages =
          (with pkgs.kdePackages; [
            discover
            kaccounts-integration
            kaccounts-providers
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
    homeManager =
      { pkgs, ... }:
      {
        imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

        home.packages = with pkgs; [
          kde-rounded-corners
          kdotool
        ];

        programs.plasma = {
          enable = true;
          overrideConfig = true;

          krunner.activateWhenTypingOnDesktop = false;

          session = {
            general.askForConfirmationOnLogout = false;
            sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";
          };

          workspace = {
            enableMiddleClickPaste = false;
            clickItemTo = "select";
            colorScheme = "BreezeDark";
            splashScreen.engine = "none";
            splashScreen.theme = "none";
            tooltipDelay = 1;
          };

          configFile = {
            klipperrc.General.MaxClipItems = 1000;
            kiorc.Confirmations.ConfirmDelete = false;
            spectaclerc = {
              Annotations.annotationToolType = 8;
              General = {
                launchAction = "DoNotTakeScreenshot";
                showCaptureInstructions = false;
                showMagnifier = "ShowMagnifierAlways";
              };
              ImageSave.imageCompressionQuality = 100;
            };
          };

          dataFile = {
            "dolphin/view_properties/global/.directory"."Dolphin"."ViewMode" = 1;
            "dolphin/view_properties/global/.directory"."Settings"."HiddenFilesShown" = true;
          };
        };
      };
  };

  flake-file.inputs.plasma-manager = {
    url = "github:nix-community/plasma-manager";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };
}
