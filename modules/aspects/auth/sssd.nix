_: {
  # System login via Authentik's LDAP outpost. SSSD caches credentials, so a
  # host that has logged a user in once keeps working offline. PAM tries the
  # (locked, password-less) local account first, then falls through to SSSD.
  #
  # The LDAP bind DN + password are NOT in this static config — the OpenBao
  # agent renders both into /etc/sssd/conf.d/01-ldap-bind.conf at runtime from
  # secret/authentik/ldap-service-account (see openbao-agent.nix).
  den.aspects.sssd = {
    nixos = _: {
      services.sssd = {
        enable = true;
        config = ''
          [sssd]
          services = nss, pam
          domains = singerfamily

          [nss]

          [pam]

          [domain/singerfamily]
          id_provider = ldap
          auth_provider = ldap

          # Local Authentik LDAP outpost (see authentik-ldap-outpost.nix).
          # Loopback only — LDAP never leaves the host, so no TLS is needed.
          ldap_uri = ldap://localhost:3389
          # Authentik's default LDAP outpost tree.
          ldap_search_base = dc=ldap,dc=goauthentik,dc=io
          ldap_user_search_base = ou=users,dc=ldap,dc=goauthentik,dc=io
          ldap_group_search_base = ou=groups,dc=ldap,dc=goauthentik,dc=io
          ldap_default_authtok_type = password

          # Authentik's LDAP outpost is AD-shaped: the POSIX login name lives
          # in `cn` (and `sAMAccountName`), while the `uid` attribute holds an
          # opaque hash. SSSD's default rfc2307 schema keys users off `uid`,
          # so it would query (uid=<name>) and never match. Use rfc2307bis and
          # point the name attribute at `cn`; objectClass `user`/`group` are
          # the AD-style classes the outpost emits alongside posixAccount.
          ldap_schema = rfc2307bis
          ldap_user_object_class = user
          ldap_user_name = cn
          ldap_user_uid_number = uidNumber
          ldap_user_gid_number = gidNumber
          ldap_user_home_directory = homeDirectory
          ldap_group_object_class = group
          ldap_group_name = cn

          # Authentik does not export a loginShell, so the directory entry
          # has an empty shell field — give LDAP users a real shell.
          default_shell = /run/current-system/sw/bin/bash

          # Outpost is on loopback — never traverses the network. SSSD
          # otherwise upgrades auth binds to StartTLS by default, which
          # the outpost rejects with a TLS handshake error.
          ldap_auth_disable_tls_never_use_in_production = true
          ldap_id_use_start_tls = false

          # Offline-safe logins.
          cache_credentials = true

          # Do not pull the whole directory. Users and their homes are
          # declared in the flake; a user must already be known to the host.
          enumerate = true
        '';
      };

      # Prefer the local outpost to be up first. Soft ordering only — SSSD's
      # credential cache must still let logins through if the outpost is down.
      systemd.services.sssd = {
        after = [ "docker-authentik-ldap.service" ];
        wants = [ "docker-authentik-ldap.service" ];
      };
    };
  };
}
