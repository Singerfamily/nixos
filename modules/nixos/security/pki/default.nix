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
      MIIDtzCCAp+gAwIBAgIIAvOT+dMP2LQwDQYJKoZIhvcNAQELBQAwQjEoMCYGA1UE
      AwwfVW5pRmkgU1NMIENlcnRpZmljYXRlIEF1dGhvcml0eTEWMBQGA1UECgwNVWJp
      cXVpdGkgSW5jLjAeFw0yNTA5MTAyMTU2MjZaFw0zNTA5MDgyMTU2MjZaMEIxKDAm
      BgNVBAMMH1VuaUZpIFNTTCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkxFjAUBgNVBAoM
      DVViaXF1aXRpIEluYy4wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDW
      Oav/pg0vAX123cDR7pz+6Aa92XSOn/N27IiNU8CyiDX0wHss0gL/pCtfGYOub+k8
      wYhsgckWkFpcwXh/3oDssQkZLnd6lPT+S68LqAd9atZsYsuODoeL05ENLBGHiKm+
      I/AUXDZSH3TuM14UrRvdm7BJTi/WeSH5NCKZpsE/NzQMlzN2Hp7888O6yG03WeZe
      tmlAlbEYgX+sxchdoj3uyiLp1wDncF/kOanZSdZWIaa3jlCxQLgkLib+mDl9KkWx
      +wwXkyV4aSP7f18zxYqB7uw1M7D4N0Ros8e0u9ae7S5rc5cYhSlmus1PFlSPwmFL
      AXBL57vh+8Y89PPQPDyLAgMBAAGjgbAwga0wCwYDVR0PBAQDAgEGMAwGA1UdEwQF
      MAMBAf8wcQYDVR0jBGowaIAUz5ms0uNEfJUKlU2ZX8EIdVukQCShRqREMEIxKDAm
      BgNVBAMMH1VuaUZpIFNTTCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkxFjAUBgNVBAoM
      DVViaXF1aXRpIEluYy6CCALzk/nTD9i0MB0GA1UdDgQWBBTPmazS40R8lQqVTZlf
      wQh1W6RAJDANBgkqhkiG9w0BAQsFAAOCAQEAF2h5ga6p/DtPpSv1RDtfmge9wlwI
      thIqf/4Li3EFQ/QBl7TombTiPsvA4bsqBGUK3QX34pyMHXFeRJb7gJI87eXFVxyG
      AI9d8Y4bY7qWrVJEOq0RYBu8O9CskmMfQ+zpchTGNDSn1k5KaSlp+QjgfP4bWKd5
      W15MP4ueQ/lrcgKV8Wg+rgKhj5bXm5LAaiPKjflLCSBW+SIGvYbsr1gDfIT/d7f0
      h4VtJOp1T/8g6D83ymGRKDr8jIm8PNUwTyyGNsO6Jfrf+jxaS4SdfhQmgthv4TUX
      ax/Vr7nPzmr7te6Mwejcf5OJCGTpoK51bpIbuL5t9NZfhsKK81wpl3Qd5g==
      -----END CERTIFICATE-----
    ''
  ];
}
