_:
{
  # Local-only break-glass administrator. Never backed by SSSD/LDAP, so it
  # still works when OpenBao *and* Authentik are both unreachable. Paired with
  # the sops-provisioned root password as the recovery path of last resort.
  #
  # Requires the `passwords/recovery` sops secret — see modules/secrets/sops.nix.
  den.aspects.recovery-account = {
    nixos =
      { config, ... }:
      {
        users.mutableUsers = false;

        users.users.recovery = {
          isNormalUser = true;
          description = "Local emergency administrator";
          extraGroups = [ "wheel" ];
          hashedPasswordFile = config.sops.secrets."passwords/recovery".path;
        };
      };
  };
}
