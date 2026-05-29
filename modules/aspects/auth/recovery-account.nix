_: {
  # Local-only break-glass administrator. Never backed by SSSD/LDAP, so it
  # still works when OpenBao *and* Authentik are both unreachable. Paired with
  # the sops-provisioned root password as the recovery path of last resort.
  #
  # Requires the `passwords/recovery` sops secret — see modules/secrets/sops.nix.
  den.aspects.recovery-account = {
    nixos =
      { config, ... }:
      {
        # System-wide: all accounts are declared in the flake, none mutable at
        # runtime. Required so the recovery account's hashedPasswordFile (and
        # root's, see modules/secrets/sops.nix) is authoritative.
        users.mutableUsers = false;

        users.users.recovery = {
          isNormalUser = true;
          description = "Local emergency administrator";
          extraGroups = [ "wheel" ];
          hashedPasswordFile = config.sops.secrets."passwords/recovery".path;
        };

        # Keep the break-glass account out of the SDDM user list. Merges with
        # the Users section set by the plasma aspect; harmless on hosts without
        # SDDM since the option simply goes unused.
        services.displayManager.sddm.settings.Users.HideUsers = "recovery";
      };
  };
}
