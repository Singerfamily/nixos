_:
{
  # Trust the OpenBao PKI root CA system-wide so TLS handshakes to
  # secrets.singerfamily.ca and the Authentik LDAP outpost validate.
  #
  # A CA certificate is public, not a secret, so the PEM is committed inline
  # here (same approach as a vendored corporate CA). This is independent of the
  # CA bundle injected at install time for early-boot use — see scripts/deploy.sh.
  #
  # TODO before deploy: paste the real OpenBao root CA PEM below. If the
  # Authentik LDAP cert chains to a different CA, add that PEM too.
  den.aspects.openbao-ca = {
    nixos =
      _:
      {
        security.pki.certificates = [
          ''
            -----BEGIN CERTIFICATE-----
            PLACEHOLDER — replace with the OpenBao PKI root CA certificate.
            -----END CERTIFICATE-----
          ''
        ];
      };
  };
}
