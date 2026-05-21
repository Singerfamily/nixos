_: {
  # Trust the OpenBao PKI root CA system-wide so TLS handshakes to
  # secrets.singerfamily.ca and the Authentik LDAP outpost validate.
  #
  # A CA certificate is public, not a secret, so the PEM is committed inline
  # here (same approach as a vendored corporate CA). This is independent of the
  # CA bundle injected at install time for early-boot use — see scripts/deploy.sh.
  #
  # This is the "OpenBao Host CA" root generated in the pki/ mount. If the
  # Authentik LDAP cert chains to a different CA, add that PEM to the list too.
  den.aspects.openbao-ca = {
    nixos = _: {
      security.pki.certificates = [
        ''
          -----BEGIN CERTIFICATE-----
          MIIBmTCCAT+gAwIBAgIUJ26MtbrWJD+5ZJl0WSrgab84tx4wCgYIKoZIzj0EAwIw
          GjEYMBYGA1UEAxMPT3BlbkJhbyBIb3N0IENBMB4XDTI2MDUyMTAwNTg1NloXDTM2
          MDUxODAwNTkyNlowGjEYMBYGA1UEAxMPT3BlbkJhbyBIb3N0IENBMFkwEwYHKoZI
          zj0CAQYIKoZIzj0DAQcDQgAEloiuKpaGGmwVr0gsgpo9jeYBnDDiK3iaadJNeYRX
          nQLZBVTlv3VoXg0CC7YeA97v+sj4jNSHm24pVRl+W6er3aNjMGEwDgYDVR0PAQH/
          BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFNnbEvrqnLRBbinIWbA3
          JETnr99oMB8GA1UdIwQYMBaAFNnbEvrqnLRBbinIWbA3JETnr99oMAoGCCqGSM49
          BAMCA0gAMEUCIQD4MO5fC0jHpek+uHaDpdAIME6OcSX8fmovhcx/BcRP0wIgE9U1
          OKL/a72VGk45hx3EKLynOxtGI/l3yGmSOKz2NDo=
          -----END CERTIFICATE-----
        ''
      ];
    };
  };
}
