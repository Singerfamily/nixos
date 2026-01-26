# INFO: Home-manager C/C++ module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.dev.c = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    embedded = mkOption {
      type = types.bool;
      default = false;
      description = "Include embedded development tools";
    };
  };

  config = mkIf config.snowfall.dev.c.enable {
    home.packages =
      let
        inherit (config.snowfall.dev.c) embedded;
      in
      mkMerge [
        (with pkgs; [
          cmake
          gcc
          gnumake

        ])

        (mkIf (embedded == false) (
          with pkgs;
          [
            gdb # included by gcc-arm-embedded
          ]
        ))

        (mkIf embedded (
          with pkgs;
          [
            stlink
            openocd
            platformio-core
            gcc-arm-embedded
            esptool
          ]
        ))
      ];
  };
}
