{ config, lib, ... }:

with lib;
{
  options.snowfall.security.pki = {
    enable = mkOption {
      type = types.bool;
      default = builtins.elem config.snowfall.core.type [
        "desktop"
        "laptop"
      ];
      description = ''
        Configure PKI (Public Key Infrastructure) with custom CA certificates.

        Scoped to current network topology.
      '';
    };
  };

  config.security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIIDtzCCAp+gAwIBAgIISCFzuoS7IyUwDQYJKoZIhvcNAQELBQAwQjEoMCYGA1UE
      AwwfVW5pRmkgU1NMIENlcnRpZmljYXRlIEF1dGhvcml0eTEWMBQGA1UECgwNVWJp
      cXVpdGkgSW5jLjAeFw0yNjAyMDUxMzU1MDlaFw0zNjAyMDMxMzU1MDlaMEIxKDAm
      BgNVBAMMH1VuaUZpIFNTTCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkxFjAUBgNVBAoM
      DVViaXF1aXRpIEluYy4wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCw
      6G2wX+9VbT9sp9gcTQm3up5mnP3M8K6nEtH+FCWVk+W7ZWUns4B8XdzJrKKKlat8
      bVKuX8fRUBxvfeq2KrUqu1XgujhLZMBb/zlO3NPIiJVfIHCLkKEVmY8Ku8SkB2Se
      kdYkY2TkLeM/UZT8ij1lr3RnLf4amTZlaNQzMpZR1f0TRxRpsn4IsOmWh3G13OYR
      leZ8Ub4GCc9XYW3w/oYfD+iCGtBtlHVtg3gfcGlHsRgLczjFDJ4GU8Q9hUbR3Zo/
      81hskKaDPYa9Cf4zJIIegsp+0s4xbZ2pGTXrlwekBMe9kjJO/LPnSdu3T5godERm
      tmicoO8kkve+FD1VYhY9AgMBAAGjgbAwga0wCwYDVR0PBAQDAgEGMAwGA1UdEwQF
      MAMBAf8wcQYDVR0jBGowaIAUm/ohjdXV9q2SEJAjZyNXle5j5TuhRqREMEIxKDAm
      BgNVBAMMH1VuaUZpIFNTTCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkxFjAUBgNVBAoM
      DVViaXF1aXRpIEluYy6CCEghc7qEuyMlMB0GA1UdDgQWBBSb+iGN1dX2rZIQkCNn
      I1eV7mPlOzANBgkqhkiG9w0BAQsFAAOCAQEADGmMGOXx2JB4X44/KjnaxSKe4Sdd
      li6VBaj8LESmowW//bQDOgDN7JQsJRZxnofF5S8hwN2jy6hnMakUXbaFQn7fk5Aw
      YGrP2u49iTd8XqXyvLfDQP3wjteeKR0XbhBXtJx/cIY43yQgBtLgDev3XqSabAQi
      u4HbXG6TaAwyTkOuJj8khoeQwFGjwb1qRl4V0qbNNuQe4Y86OXDubAi9o7nR21x3
      sFM5M9dHbKjzzg8b9FTh1U5TFiPaaMgSIl05PvxrvFVNeYoLJKu3t5DXPEAmLveI
      O9D1qHMYBTBW1ee+awWE1WztsaH7KjSaXtuFEXsms6Rwa3Yczy5rqw9aOg==
      -----END CERTIFICATE-----
    ''
  ];
}
