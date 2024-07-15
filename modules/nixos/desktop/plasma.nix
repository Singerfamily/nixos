{pkgs, ...}: {
  services.displayManager.sddm ={
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  # services.xserver.xkb = {
  #   layout = "us";
  #   variant = "";
  # };

  environment.systemPackages = with pkgs; [
    aha
    fwupd
    vulkan-tools
    wayland-utils
    pciutils
    discover
  ];
}