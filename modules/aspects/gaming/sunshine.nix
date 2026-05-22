_: {
  den.aspects.sunshine = {
    nixos =
      { pkgs, ... }:
      {
        services.sunshine = {
          enable = true;
          autoStart = true;
          # CAP_SYS_ADMIN: required for Sunshine's virtual-display / KMS
          # capture path.
          capSysAdmin = true;
          openFirewall = true;
        };

        services.udev.extraRules = ''
          KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
        '';

        # gnome-remote-desktop coexists with KDE portal — used only for ScreenCast/RemoteDesktop protocols
        services.gnome.gnome-remote-desktop.enable = true;
        xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
        xdg.portal.config.common = {
          "org.freedesktop.impl.portal.ScreenCast" = "gnome";
          "org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
        };
      };
  };
}
