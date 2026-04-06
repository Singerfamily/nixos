{ den, ... }:
{
  den.default.nixos =
    { pkgs, lib, ... }:
    {
      fonts.packages = (
        with pkgs;
        [
          nerd-fonts.jetbrains-mono
          nerd-fonts.meslo-lg
        ]
      );
      fonts.fontconfig.defaultFonts = {
        serif =  [ "JetBrainsMono Nerd Font" ];
        sansSerif =  [ "JetBrainsMono Nerd Font" ];
        monospace =  [ "JetBrainsMono Nerd Font Mono" ];
      };
    };
}
