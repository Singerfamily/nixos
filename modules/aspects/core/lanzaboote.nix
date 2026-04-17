{ inputs, ... }:
{
  # Lanzaboote UEFI Secure Boot. Add to host includes to enable.
  # Requires: sbctl enrolled keys in /var/lib/sbctl
  # Overrides systemd-boot — set boot.loader.systemd-boot.enable = false in host.
  den.aspects.lanzaboote.nixos =
    { lib, pkgs, ... }:
    {
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];
      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
      # systemd-boot must be disabled when lanzaboote is active
      boot.loader.systemd-boot.enable = lib.mkForce false;
      environment.systemPackages = [ pkgs.sbctl ];
    };
}
