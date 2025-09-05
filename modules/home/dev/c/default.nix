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
      with pkgs;
      mkMerge [
        [
          cmake
          gcc
          gnumake

        ]

        (mkIf (embedded == false) [
          gdb # included by gcc-arm-embedded
        ])

        (mkIf embedded [
          stlink
          openocd
          platformio-core
          gcc-arm-embedded
        ])
      ];
  };
}
