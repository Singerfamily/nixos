{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  home.packages = with pkgs; [
    kara
    kde-rounded-corners
    kdePackages.krohnkite
    kdotool
  ];

  # Set gpg agent specific to KDE/Kwallet
  services.gpg-agent = {
    pinentry.package = lib.mkForce pkgs.kwalletcli;
    extraConfig = "pinentry-program ${pkgs.kwalletcli}/bin/pinentry-kwallet";
  };

  programs.plasma = {
    enable = true;

    fonts = {
      fixedWidth = {
        family = "JetBrainsMono Nerd Font Mono";
        pointSize = 10;
      };
      general = {
        family = "JetBrainsMono Nerd Font";
        pointSize = 10;
      };
      menu = {
        family = "JetBrainsMono Nerd Font";
        pointSize = 10;
      };
      small = {
        family = "JetBrainsMono Nerd Font";
        pointSize = 8;
      };
      toolbar = {
        family = "JetBrainsMono Nerd Font";
        pointSize = 10;
      };
      windowTitle = {
        family = "JetBrainsMono Nerd Font";
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
        # layouts = [
        #   # {
        #   #   layout = "pl";
        #   # }
        #   # {
        #   #   layout = "ru";
        #   # }
        #   {
        #   }
        # ];
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
      # touchpads = [
      #   {
      #     disableWhileTyping = true;
      #     enable = true;
      #     leftHanded = false;
      #     middleButtonEmulation = true;
      #     name = "ELAN06A0:00 04F3:3231 Touchpad";
      #     naturalScroll = true;
      #     pointerSpeed = 0;
      #     productId = "3231";
      #     tapToClick = true;
      #     vendorId = "04f3";
      #   }
      # ];
    };

    krunner.activateWhenTypingOnDesktop = false;

    kscreenlocker = {
      # appearance.wallpaper = "${config.wallpaper}";
      autoLock = true;
      timeout = 300; # 5 minutes
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
        floating = false;
        height = 34;
        lengthMode = "fill";
        location = "top";
        opacity = "translucent";
        widgets = [
          "org.kde.plasma.kickoff"
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
          {
            name = "org.kde.plasma.digitalclock";
            config = {
              Appearance = {
                dateDisplayFormat = "BesideTime";
                dateFormat = "custom";
                use24hFormat = 2;
              };
            };
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
                  # "org.kde.kdeconnect"
                  "org.kde.plasma.bluetooth"
                  # {
                  #   name = "org.kde.plasma.weather";
                  #   config = {
                  #     WeatherStation.source = "Calgary, AB (Environment Canada)";
                  #   };
                  # }
                ];
                # hidden = [
                #   "org.kde.plasma.cameraindicator"
                #   "org.kde.plasma.brightness"
                #   "org.kde.plasma.clipboard"
                #   "org.kde.plasma.devicenotifier"
                #   "plasmashell_microphone"
                # ];
                # configs = {
                #   "org.kde.plasma.notifications".config = {
                #     Shortcuts = {
                #       global = "Meta+V";
                #     };
                #   };
                #   "org.kde.plasma.clipboard".config = {
                #     Shortcuts = {
                #       global = "Alt+Shift+V";
                #     };
                #   };
                # };
              };
            };
          }
        ];

        screen = "all";
      }
    ];

    powerdevil = {
      AC = {
        autoSuspend.action = "nothing";
        dimDisplay.enable = false;
        powerButtonAction = "shutDown";
        turnOffDisplay.idleTimeout = 300;
      };
      # battery = {
      #   autoSuspend.action = "nothing";
      #   dimDisplay.enable = false;
      #   powerButtonAction = "shutDown";
      #   turnOffDisplay.idleTimeout = "never";
      # };
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
      # {
      #   apply = {
      #     noborder = {
      #       value = true;
      #       apply = "initially";
      #     };
      #   };
      #   description = "Hide titlebar by default";
      #   match = {
      #     window-class = {
      #       value = ".*";
      #       type = "regex";
      #     };
      #   };
      # }
      # {
      #   apply = {
      #     desktops = "Desktop_1";
      #     desktopsrule = "3";
      #   };
      #   description = "Assign Brave to Desktop 1";
      #   match = {
      #     window-class = {
      #       value = "brave-browser";
      #       type = "substring";
      #     };
      #     window-types = [ "normal" ];
      #   };
      # }
      # {
      #   apply = {
      #     desktops = "Desktop_2";
      #     desktopsrule = "3";
      #   };
      #   description = "Assign Alacritty to Desktop 2";
      #   match = {
      #     window-class = {
      #       value = "Alacritty";
      #       type = "substring";
      #     };
      #     window-types = [ "normal" ];
      #   };
      # }
      # {
      #   apply = {
      #     desktops = "Desktop_3";
      #     desktopsrule = "3";
      #   };
      #   description = "Assign Telegram to Desktop 3";
      #   match = {
      #     window-class = {
      #       value = "org.telegram.desktop";
      #       type = "substring";
      #     };
      #     window-types = [ "normal" ];
      #   };
      # }
      # {
      #   apply = {
      #     desktops = "Desktop_4";
      #     desktopsrule = "3";
      #   };
      #   description = "Assign OBS to Desktop 4";
      #   match = {
      #     window-class = {
      #       value = "com.obsproject.Studio";
      #       type = "substring";
      #     };
      #     window-types = [ "normal" ];
      #   };
      # }
      # {
      #   apply = {
      #     desktops = "Desktop_4";
      #     desktopsrule = "3";
      #     minimizerule = "2";
      #   };
      #   description = "Assign Steam to Desktop 4";
      #   match = {
      #     window-class = {
      #       value = "steam";
      #       type = "exact";
      #       match-whole = false;
      #     };
      #     window-types = [ "normal" ];
      #   };
      # }
      # {
      #   apply = {
      #     desktops = "Desktop_5";
      #     desktopsrule = "3";
      #   };
      #   description = "Assign Steam Games to Desktop 5";
      #   match = {
      #     window-class = {
      #       value = "steam_app_";
      #       type = "substring";
      #       match-whole = false;
      #     };
      #   };
      # }
      # {
      #   apply = {
      #     desktops = "Desktop_5";
      #     desktopsrule = "3";
      #     minimizerule = "2";
      #   };
      #   description = "Assign Zoom to Desktop 5";
      #   match = {
      #     window-class = {
      #       value = "zoom";
      #       type = "substring";
      #     };
      #     window-types = [ "normal" ];
      #   };
      # }
    ];

    workspace = {
      enableMiddleClickPaste = false;
      clickItemTo = "select";
      colorScheme = "BreezeDark";
      # cursor.theme = "Yaru";
      splashScreen.engine = "none";
      splashScreen.theme = "none";
      tooltipDelay = 1;
      # wallpaper = "${config.wallpaper}";
    };

    configFile = {
      baloofilerc."Basic Settings"."Indexing-Enabled" = false;
      kdeglobals = {
        # General = {
        #   BrowserApplication = "brave-browser.desktop";
        # };
        # Icons = {
        #   Theme = "Tela-circle-dark";
        # };
        # KDE = {
        #   AnimationDurationFactor = 0;
        # };
      };
      klipperrc.General.MaxClipItems = 1000;
      kiorc.Confirmations.ConfirmDelete = false;
      kwinrc = {
        Effect-overview.BorderActivate = 9;
        Plugins = {
          krohnkiteEnabled = true;
        };
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
        "Script-krohnkite" = {
          # floatingClass = "ulauncher,brave-nngceckbapebfimnlniiiahkandclblb-Default";
          screenGapBetween = 3;
          screenGapBottom = 3;
          screenGapLeft = 3;
          screenGapRight = 3;
          screenGapTop = 3;
        };
        # Windows = {
        #   DelayFocusInterval = 0;
        #   # FocusPolicy = "FocusFollowsMouse";
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
