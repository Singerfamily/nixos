{ den, ... }:
{
  den.aspects.dev-c = {
    includes = [ den.aspects.dev ];
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
  den.aspects.dev-embedded = {
    includes = [ den.aspects.dev-c ];
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
