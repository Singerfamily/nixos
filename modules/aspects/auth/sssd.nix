_:
{
  # System login via Authentik's LDAP outpost. SSSD caches credentials, so a
  # host that has logged a user in once keeps working offline. PAM tries the
  # (locked, password-less) local account first, then falls through to SSSD.
  #
  # The LDAP bind password is NOT in this static config — the OpenBao agent
  # renders it into /etc/sssd/conf.d/01-ldap-bind.conf at runtime
  # (see modules/aspects/services/openbao-agent.nix).
  #
  # TODO before deploy: replace the ldap_uri / ldap_search_base /
  # ldap_default_bind_dn placeholders with the real Authentik LDAP values.
  den.aspects.sssd = {
    nixos =
      _:
      {
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

            # TODO: real Authentik LDAP outpost hostname.
            ldap_uri = ldaps://auth.singerfamily.ca
            # TODO: real directory base DN.
            ldap_search_base = dc=singerfamily,dc=ca
            # TODO: real SSSD service-account bind DN.
            ldap_default_bind_dn = cn=sssd,ou=users,dc=singerfamily,dc=ca
            ldap_default_authtok_type = password

            # TLS to the outpost validated against the OpenBao-issued CA.
            ldap_tls_reqcert = demand
            ldap_tls_cacert = /etc/openbao/tls/ca.crt

            # Offline-safe logins.
            cache_credentials = true

            # Do not pull the whole directory. Users and their homes are
            # declared in the flake; a user must already be known to the host.
            enumerate = false
          '';
        };
      };
  };
}
