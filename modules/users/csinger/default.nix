{ den, inputs, ... }:
{
  den.aspects.csinger = {
    includes = [
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")
    ];

    user = {
      name = "csinger";
      description = "Clint Singer";
    };

    nixos =
      { pkgs, ... }:
      {
        fonts.packages = with pkgs; [
          nerd-fonts.jetbrains-mono
        ];

        fonts.fontconfig.defaultFonts = {
          serif = [ "JetBrainsMono Nerd Font" ];
          sansSerif = [ "JetBrainsMono Nerd Font" ];
          monospace = [ "JetBrainsMono Nerd Font Mono" ];
        };
      };

    homeManager = {
      imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

      programs.plasma = {
        fonts =
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
      };
    };
  };
}
