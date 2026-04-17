{ den, ... }:
{
  # Shared KWin settings - virtual desktops, night light, effects, round corners
  den.aspects.plasma-kwin = {
    includes = [ den.aspects.plasma ];
    homeManager =
      { lib, ... }:
      {
        programs.plasma = {

          fonts = {
            fixedWidth = {
              family = lib.mkDefault "JetBrainsMono Nerd Font Mono";
              pointSize = lib.mkDefault 10;
            };
            general = {
              family = lib.mkDefault "JetBrainsMono Nerd Font";
              pointSize = lib.mkDefault 10;
            };
            menu = {
              family = lib.mkDefault "JetBrainsMono Nerd Font";
              pointSize = lib.mkDefault 10;
            };
            small = {
              family = lib.mkDefault "JetBrainsMono Nerd Font";
              pointSize = lib.mkDefault 8;
            };
            toolbar = {
              family = lib.mkDefault "JetBrainsMono Nerd Font";
              pointSize = lib.mkDefault 10;
            };
            windowTitle = {
              family = lib.mkDefault "JetBrainsMono Nerd Font";
              pointSize = lib.mkDefault 10;
            };
          };

          kwin = {
            effects.desktopSwitching.animation = "fade";
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

          # Round corners via configFile
          configFile.kwinrc."Round-Corners" = {
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
          configFile.kwinrc.Effect-overview.BorderActivate = 9;
        };
      };
  };
}
