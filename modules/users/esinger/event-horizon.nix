_: {
  den.aspects.eric.provides.event-horizon.homeManager =
    { pkgs, ... }:
    let
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Kay/contents/images_dark/5120x2880.png";
    in
    {
      programs.plasma = {
        workspace.wallpaper = wallpaper;

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

        kscreenlocker = {
          appearance.wallpaper = wallpaper;
          autoLock = true;
          timeout = 15; # minutes; home desktop, longer idle acceptable
        };

        hotkeys.commands.launch-edge = {
          name = "Launch Edge";
          key = "Meta+Shift+E";
          command = "${pkgs.microsoft-edge}/bin/microsoft-edge";
        };

        panels = [
          {
            location = "bottom";
            height = 36;
            screen = "all";
            widgets = [
              {
                name = "org.kde.plasma.kickoff";
                config.General = {
                  icon = "nix-snowflake-white";
                  alphaSort = true;
                };
              }
              {
                iconTasks.launchers = [
                  "applications:org.kde.konsole.desktop"
                  "applications:org.kde.dolphin.desktop"
                  "applications:microsoft-edge.desktop"
                  "applications:code.desktop"
                  "applications:vesktop.desktop"
                  "applications:steam.desktop"
                ];
              }
              "org.kde.plasma.panelspacer"
              {
                systemTray.items = {
                  showAll = false;
                  shown = [
                    "org.kde.plasma.volume"
                    "org.kde.plasma.bluetooth"
                  ];
                };
              }
              {
                digitalClock = {
                  calendar.firstDayOfWeek = "sunday";
                  time.format = "24h";
                };
              }
            ];
          }
        ];

        configFile = {
          klipperrc.General.MaxClipItems = 1000;
          kwinrc.Plugins.krohnkiteEnabled = true;
          kwinrc."Script-krohnkite" = {
            screenGapBetween = 3;
            screenGapBottom = 3;
            screenGapLeft = 3;
            screenGapRight = 3;
            screenGapTop = 3;
          };
        };
      };
    };
}
