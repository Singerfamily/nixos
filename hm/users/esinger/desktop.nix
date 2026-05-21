# esinger — portable desktop home-manager config (graphical managed hosts only).
_:
{
  programs.plasma.fonts =
    let
      font = {
        family = "JetBrainsMono Nerd Font";
        pointSize = 10;
      };
    in
    {
      general = font;
      menu = font;
      toolbar = font;
      windowTitle = font;
      fixedWidth = font // {
        family = "JetBrainsMono Nerd Font Mono";
      };
      small = font // {
        pointSize = 8;
      };
    };
}
