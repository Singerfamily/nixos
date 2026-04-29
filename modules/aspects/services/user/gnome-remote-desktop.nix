_:
{
  # GNOME Remote Desktop over RDP — works with Wayland via Pipewire without
  # requiring the full GNOME desktop. Uses xdg-desktop-portal-gnome for the
  # screencast and remote-desktop portals.
  den.aspects.gnome-remote-desktop.nixos =
    { pkgs, ... }:
    {
      services.gnome.gnome-remote-desktop.enable = true;
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
      xdg.portal.config.common = {
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        "org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
      };
      networking.firewall.allowedTCPPorts = [ 3389 ];
    };
}
