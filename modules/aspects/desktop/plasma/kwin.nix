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
            effects.desktopSwitching.animation = lib.mkDefault "fade";
            nightLight = {
              enable = lib.mkDefault true;
              location.latitude = lib.mkDefault "50.88";
              location.longitude = lib.mkDefault "-113.96";
              mode = lib.mkDefault "location";
              temperature.night = lib.mkDefault 4000;
            };
            virtualDesktops = {
              number = lib.mkDefault 5;
              rows = lib.mkDefault 1;
            };
          };

          # Round corners via configFile
          configFile.kwinrc."Round-Corners" = {
            ActiveOutlineAlpha = lib.mkDefault 255;
            ActiveOutlineUseCustom = lib.mkDefault false;
            ActiveOutlineUsePalette = lib.mkDefault true;
            ActiveSecondOutlineUseCustom = lib.mkDefault false;
            ActiveSecondOutlineUsePalette = lib.mkDefault true;
            DisableOutlineTile = lib.mkDefault false;
            DisableRoundTile = lib.mkDefault false;
            InactiveCornerRadius = lib.mkDefault 8;
            InactiveOutlineAlpha = lib.mkDefault 0;
            InactiveOutlineUseCustom = lib.mkDefault false;
            InactiveOutlineUsePalette = lib.mkDefault true;
            InactiveSecondOutlineAlpha = lib.mkDefault 0;
            InactiveSecondOutlineThickness = lib.mkDefault 0;
            OutlineThickness = lib.mkDefault 1;
            SecondOutlineThickness = lib.mkDefault 0;
            Size = lib.mkDefault 8;
          };
          configFile.kwinrc.Effect-overview.BorderActivate = lib.mkDefault 9;
        };
      };
  };
}
