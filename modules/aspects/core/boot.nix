{ den, ... }:
{
  # Default boot config: systemd-boot UEFI
  # Hosts can override or use lanzaboote for secure boot
  den.default.nixos = { lib, ... }: {
    boot.loader = {
      systemd-boot.enable =  true;
      efi.canTouchEfiVariables =  true;
    };
    # Don't wait for network or plymouth at boot
    systemd.services.NetworkManager-wait-online.enable =  false;
    systemd.services.plymouth-quit-wait.enable =  false;
  };
}
