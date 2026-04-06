{ den, ... }:
{
  # Shared keyboard shortcuts - both users use the same bindings
  den.aspects.plasma-keybinds = {
    includes = [ den.aspects.plasma ];
    homeManager = { lib, ... }: {
      programs.plasma = {
        shortcuts = {
          ksmserver = {
            "Lock Session" = [ "Screensaver" "Meta+L" ];
            "LogOut" = [ "Meta+Shift+Q" ];
          };
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
          "services/org.kde.dolphin.desktop"."_launch" = "Meta+E";
        };

        spectacle.shortcuts = {
          captureEntireDesktop =  "Meta+Ctrl+S";
          captureRectangularRegion =  "Meta+Shift+S";
          recordRegion =  "Meta+Shift+R";
        };
      };
    };
  };
}
