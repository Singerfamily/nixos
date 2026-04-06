{ den, ... }:
{
  den.aspects.fonts = {
    nixos = { pkgs, lib, ... }: {
      fonts.packages = (with pkgs; [
        nerd-fonts.jetbrains-mono
        nerd-fonts.meslo-lg
      ]);
      fonts.fontconfig.defaultFonts = {
        serif = lib.mkDefault [ "JetBrainsMono Nerd Font" ];
        sansSerif = lib.mkDefault [ "JetBrainsMono Nerd Font" ];
        monospace = lib.mkDefault [ "JetBrainsMono Nerd Font Mono" ];
      };
    };
  };
}
