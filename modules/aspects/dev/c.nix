{ dev, ... }:
{
  dev.c = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          cmake
          gcc
          gnumake
        ];
      };
  };

  # Embedded sub-aspect for STM32/ARM development
  dev.embedded = {
    includes = [ dev.c ];
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          stlink
          openocd
          gdb
          gcc-arm-embedded-13
          platformio-core
          esptool
        ];
      };
  };
}
