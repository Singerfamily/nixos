_:
{
  # CIFS/SMB client utilities. Hosts that mount shares declare the mount
  # themselves (via fileSystems."/mnt/X" = { fsType = "cifs"; ... }) — this
  # aspect just provides the tooling and marks it opt-in.
  den.aspects.samba-client.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.cifs-utils ];
    };
}
