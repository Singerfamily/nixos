{libx, ...}: {
  imports = [(libx.autoImports ./.)];

  desktop.plasma.enable = libx.mkDefault true;
}