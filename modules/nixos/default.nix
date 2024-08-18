{libx, ...}: {
  imports = [
    libx.autoImport ./.
  ];

  desktop.plasma.enable = libx.mkDefault true;
}