# INFO: Core NixOS module for the default configuration.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.snowfall.core = {
    enable = mkOption {
      type = with types; bool;
      description = "Whether to enable cryptography support";
      default = true;
    };
  };

  config = {
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        inputs.unstable.nerd-fonts.monaspace
        # monaspace
        # fira-code
        # (nerd-fonts.override { fonts = [
        #   "Monaspace"
        #   "FiraCode"
        #   # "JetBrainsMono"
        #   # "DroidSansMono"
        #   ];
        # })
        corefonts
      ];

      fontconfig = {
        defaultFonts = {
          serif = [ "Monaspace" ];
          sansSerif = [ "Monaspace" ];
          monospace = [ "Monaspace" ];
        };
      };
    };

    i18n = {
      defaultLocale = lib.mkDefault "en_CA.UTF-8";
    };
    time.timeZone = lib.mkDefault "America/Edmonton";
  };
}
