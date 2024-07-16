{pkgs, ...}:

{
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-wayland";
  services.xrdp.openFirewall = true;
}