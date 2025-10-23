{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  home.packages = with pkgs; [
    kara
    kde-rounded-corners
    #kdePackages.krohnkite
    kdotool
  ];

  # Set gpg agent specific to KDE/Kwallet
  services.gpg-agent = {
    pinentry.package = lib.mkForce pkgs.kwalletcli;
    extraConfig = "pinentry-program ${pkgs.kwalletcli}/bin/pinentry-kwallet";
  };

  programs.plasma =
    let
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Autumn/contents/images/2560x1440.jpg";
    in
    {
    
    enable = true;

    fonts = {
      fixedWidth = {
        family = "JetBrainsMono Nerd Font Mono";
        pointSize = 10;
      };
      general = {
        family = "Noto Sans";
        pointSize = 10;
      };
      menu = {
        family = "Noto Sans";
        pointSize = 10;
      };
      small = {
        family = "Noto Sans";
        pointSize = 8;
      };
      toolbar = {
        family = "Noto Sans";
        pointSize = 10;
      };
      windowTitle = {
        family = "Noto Sans";
        pointSize = 10;
      };
    };

    hotkeys.commands = {
      launch-edge = {
        name = "Launch Edge";
        key = "Meta+Shift+E";
        command = "flatpak run --branch=stable --arch=x86_64 --command=/app/bin/edge --file-forwarding com.microsoft.Edge @@u %U @@";
      };
    };

    input = {
      keyboard = {        
        repeatDelay = 250;
        repeatRate = 40;
      };
      mice = [
        {
          accelerationProfile = "none";
          name = "Razer USA, Ltd Razer Naga V2 Pro";
          productId = "00a7";
          vendorId = "1532";
        }
      ];      
    };

    krunner.activateWhenTypingOnDesktop = false;

    kscreenlocker = {
      appearance.wallpaper = "${wallpaper}";
      autoLock = true;
      timeout = 10; # In minutes
    };

    kwin = {
      effects = {
        # blur.enable = false;
        # cube.enable = false;cC
        desktopSwitching.animation = "fade";
        # dimAdminMode.enable = false;
        # dimInactive.enable = false;
        # fallApart.enable = false;
        # fps.enable = false;
        # minimization.animation = "off";
        # shakeCursor.enable = false;
        # slideBack.enable = false;
        # snapHelper.enable = false;
        # translucency.enable = false;
        # windowOpenClose.animation = "off";
        # wobblyWindows.enable = false;
      };

      nightLight = {
        enable = true;
        location.latitude = "50.88";
        location.longitude = "-113.96";
        mode = "location";
        temperature.night = 4000;
      };

      virtualDesktops = {
        number = 5;
        rows = 1;
      };
    };

    overrideConfig = true;

    panels = [
      {
        screen = 0;
        floating = false;
        height = 34;
        lengthMode = "fill";
        location = "bottom";
        opacity = "translucent";
        widgets = [
          "org.kde.plasma.panelspacer"
          "org.kde.plasma.kickoff"                    
          {
            name = "org.kde.plasma.icontasks";
          }
          "org.kde.plasma.panelspacer"
          {
            systemTray = {
              items = {
                showAll = false;
                shown = [
                  "org.kde.plasma.notifications"
                  "org.kde.plasma.networkmanagement"
                  "org.kde.plasma.volume"
                  "org.kde.plasma.bluetooth"
                ];
              };
            };
          }
          {
            name = "org.kde.plasma.digitalclock";
            config = {
              Appearance = {
                # dateDisplayFormat = "BesideTime";
                # dateFormat = "custom";
                use24hFormat = 2;
              };
            };
          }
        ];
      }
      {
        screen = 1;
        floating = false;
        height = 34;
        lengthMode = "fill";
        location = "bottom";
        opacity = "translucent";
        widgets = [ 
          {
            name = "org.dhruv8sh.kara";
            config = {
              general = {
                # animationDuration = 0;
                spacing = 3;
                type = 1;
              };
              type1 = {
                fixedLen = 3;
                labelSource = 0;
              };
            };
          }
          "org.kde.plasma.panelspacer"                   
          "org.kde.plasma.kickoff"
          {
            name = "org.kde.plasma.icontasks";
          }          
          "org.kde.plasma.panelspacer"
          # {
          #   name = "org.kde.plasma.taskmanager";
          # }          
          {
            systemTray = {
              items = {
                showAll = false;
                shown = [
                  "org.kde.plasma.notifications"
                  "org.kde.plasma.networkmanagement"
                  "org.kde.plasma.volume"
                  "org.kde.plasma.bluetooth"
                ];
              };
            };
          }
          {
            name = "org.kde.plasma.digitalclock";
            config = {
              Appearance = {
                # dateDisplayFormat = "BesideTime";
                # dateFormat = "custom";
                use24hFormat = 2;
              };
            };
          }
        ];        
      }      
    ];

    powerdevil = {
      AC = {
        autoSuspend.action = "nothing";
        dimDisplay.enable = false;
        powerButtonAction = "shutDown";
        turnOffDisplay.idleTimeout = 300;
      };
      battery = {
        autoSuspend.action = "nothing";
        dimDisplay.enable = true;
        powerButtonAction = "shutDown";
        turnOffDisplay.idleTimeout = 360;
      };
    };

    session = {
      general.askForConfirmationOnLogout = false;
      sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";
    };

    shortcuts = {
      ksmserver = {
        "Lock Session" = [
          "Screensaver"
          "Meta+L"
        ];
        "LogOut" = [
          "Meta+Shift+Q"
        ];
      };

      # "KDE Keyboard Layout Switcher" = {
      #   "Switch to Next Keyboard Layout" = "Meta+Space";
      # };

      kwin = {
        "Overview" = "Meta+A";
        "Switch to Desktop 1" = "Meta+1";
        "Switch to Desktop 2" = "Meta+2";
        "Switch to Desktop 3" = "Meta+3";
        "Switch to Desktop 4" = "Meta+4";
        "Switch to Desktop 5" = "Meta+5";
        "Switch to Desktop 6" = "Meta+6";
        "Switch to Desktop 7" = "Meta+7";
        "Window Move Center" = "Ctrl+Alt+C";
        "Window Close" = "Alt+F4";
        "Window to Desktop 1" = "Meta+!";
        "Window to Desktop 2" = "Meta+@";
        "Window to Desktop 3" = "Meta+#";
        "Window to Desktop 4" = "Meta+$";
        "Window to Desktop 5" = "Meta+%";
        "Window to Desktop 6" = "Meta+^";
      };

      # plasmashell = {
      #   "show-on-mouse-pos" = "";
      # };

      "services/org.kde.dolphin.desktop"."_launch" = "Meta+E";
    };

    spectacle = {
      shortcuts = {
        captureEntireDesktop = "Meta+Ctrl+S";
        captureRectangularRegion = "Meta+Shift+S";
        recordRegion = "Meta+Shift+R";
      };
    };

    window-rules = [      
    ];

    workspace = {
      enableMiddleClickPaste = false;
      clickItemTo = "select";
      colorScheme = "BreezeDark";
      # cursor.theme = "Yaru";
      splashScreen.engine = "none";
      splashScreen.theme = "none";
      tooltipDelay = 1;
      wallpaper = "${wallpaper}";
    };

    configFile = {
      baloofilerc."Basic Settings"."Indexing-Enabled" = false;
      kdeglobals = {        
      };
      klipperrc.General.MaxClipItems = 1000;
      kiorc.Confirmations.ConfirmDelete = false;
      kwinrc = {
        Effect-overview.BorderActivate = 9;
        # Plugins = {
        #   krohnkiteEnabled = true;
        # };
        "Round-Corners" = {
          ActiveOutlineAlpha = 255;
          ActiveOutlineUseCustom = false;
          ActiveOutlineUsePalette = true;
          ActiveSecondOutlineUseCustom = false;
          ActiveSecondOutlineUsePalette = true;
          DisableOutlineTile = false;
          DisableRoundTile = false;
          InactiveCornerRadius = 8;
          InactiveOutlineAlpha = 0;
          InactiveOutlineUseCustom = false;
          InactiveOutlineUsePalette = true;
          InactiveSecondOutlineAlpha = 0;
          InactiveSecondOutlineThickness = 0;
          OutlineThickness = 1;
          SecondOutlineThickness = 0;
          Size = 8;
        };

        "Tiling/Desktop_1/b7457132-3b86-487d-82e5-b12723e589c3"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":1},{\"width\":1}]}";
        "Tiling/Desktop_1/d4f85966-0f6d-4e55-b0ed-2fabeec247f2"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"layoutDirection\":\"vertical\",\"tiles\":[{\"height\":0.36527777777777826},{\"height\":0.6347222222222206}],\"width\":0.27994791666666713},{\"layoutDirection\":\"vertical\",\"tiles\":[{\"height\":0.3657407407407405},{\"height\":0.6342592592592595}],\"width\":0.4351562500000004},{\"layoutDirection\":\"vertical\",\"tiles\":[{\"height\":0.3662037037037038},{\"height\":0.6337962962962955}],\"width\":0.28489583333333246}]}";
        "Tiling/Desktop_2/b7457132-3b86-487d-82e5-b12723e589c3"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":1},{\"width\":1}]}";
        "Tiling/Desktop_2/d4f85966-0f6d-4e55-b0ed-2fabeec247f2"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"layoutDirection\":\"vertical\",\"tiles\":[{\"height\":0.36527777777777826},{\"height\":0.6347222222222206}],\"width\":0.27994791666666713},{\"layoutDirection\":\"vertical\",\"tiles\":[{\"height\":0.3657407407407405},{\"height\":0.6342592592592595}],\"width\":0.4351562500000004},{\"layoutDirection\":\"vertical\",\"tiles\":[{\"height\":0.3662037037037038},{\"height\":0.6337962962962955}],\"width\":0.28489583333333246}]}";
        "Tiling/Desktop_3/b7457132-3b86-487d-82e5-b12723e589c3"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":1},{\"width\":1}]}";
        "Tiling/Desktop_3/d4f85966-0f6d-4e55-b0ed-2fabeec247f2"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"layoutDirection\":\"vertical\",\"tiles\":[{\"height\":0.36527777777777826},{\"height\":0.6347222222222206}],\"width\":0.27994791666666713},{\"layoutDirection\":\"vertical\",\"tiles\":[{\"height\":0.3657407407407405},{\"height\":0.6342592592592595}],\"width\":0.4351562500000004},{\"layoutDirection\":\"vertical\",\"tiles\":[{\"height\":0.3662037037037038},{\"height\":0.6337962962962955}],\"width\":0.28489583333333246}]}";
        "Tiling/Desktop_4/b7457132-3b86-487d-82e5-b12723e589c3"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":1},{\"width\":1}]}";
        "Tiling/Desktop_4/d4f85966-0f6d-4e55-b0ed-2fabeec247f2"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"layoutDirection\":\"vertical\",\"tiles\":[{\"height\":0.36527777777777826},{\"height\":0.6347222222222206}],\"width\":0.27994791666666713},{\"layoutDirection\":\"vertical\",\"tiles\":[{\"height\":0.3657407407407405},{\"height\":0.6342592592592595}],\"width\":0.4351562500000004},{\"layoutDirection\":\"vertical\",\"tiles\":[{\"height\":0.3662037037037038},{\"height\":0.6337962962962955}],\"width\":0.28489583333333246}]}";
        "Tiling/Desktop_5/b7457132-3b86-487d-82e5-b12723e589c3"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":1},{\"width\":1}]}";
        "Tiling/Desktop_5/d4f85966-0f6d-4e55-b0ed-2fabeec247f2"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"layoutDirection\":\"vertical\",\"tiles\":[{\"height\":0.36527777777777826},{\"height\":0.6347222222222206}],\"width\":0.27994791666666713},{\"layoutDirection\":\"vertical\",\"tiles\":[{\"height\":0.3657407407407405},{\"height\":0.6342592592592595}],\"width\":0.4351562500000004},{\"layoutDirection\":\"vertical\",\"tiles\":[{\"height\":0.3662037037037038},{\"height\":0.6337962962962955}],\"width\":0.28489583333333246}]}";

        "General"."FreeFloating" = true;

        # "Script-krohnkite" = {
        #   # floatingClass = "ulauncher,brave-nngceckbapebfimnlniiiahkandclblb-Default";
        #   screenGapBetween = 3;
        #   screenGapBottom = 3;
        #   screenGapLeft = 3;
        #   screenGapRight = 3;
        #   screenGapTop = 3;
        # };

        # Windows = {
        #   DelayFocusInterval = 0;
        #   FocusPolicy = "FocusFollowsMouse";
        # };
      };

      spectaclerc = {
        Annotations.annotationToolType = 8;
        General = {
          launchAction = "DoNotTakeScreenshot";
          showCaptureInstructions = false;
          showMagnifier = "ShowMagnifierAlways";
        };
        ImageSave.imageCompressionQuality = 100;
      };

      dolphinrc = {
        CompactMode = {
          IconSize = 22;
          PreviewSize = 32;          
        };
        DetailsMode = {
          IconSize = 22;
          PreviewSize = 16;
        };        
      };
    };

    dataFile = {
      "dolphin/view_properties/global/.directory"."Dolphin"."ViewMode" = 1;
      "dolphin/view_properties/global/.directory"."Settings"."HiddenFilesShown" = true;
    };

    startup.startupScript = {
      # ulauncher = {
      #   text = "ulauncher --hide-window";
      #   priority = 8;
      #   runAlways = true;
      # };
    };
  };
}
