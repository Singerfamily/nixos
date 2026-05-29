# pam_oauth2_device — a PAM module that authenticates a login via the OAuth2
# Device Authorization Grant. At a (keyboard-interactive) login prompt it shows
# a verification URL + user code (and a QR code), the user approves on a second
# device with a browser, and the module polls the token endpoint until the IdP
# confirms. The OIDC identity is then mapped to a permitted local account.
#
# Upstream is STFC's fork, which now lives at ICS-MU/pam_oauth2_device. Not in
# nixpkgs, so we build it here. Plain Makefile; nlohmann/json and the nayuki QR
# encoder are vendored in-tree, so the only external deps are pam, curl, and
# openldap (ldap + lber, for the optional LDAP bypass/preauth feature).
#
# Consumed by modules/aspects/auth/oidc-login.nix via
# inputs.self.packages.<system>.pam_oauth2_device.
{
  lib,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.pam_oauth2_device = pkgs.stdenv.mkDerivation {
        pname = "pam_oauth2_device";
        version = "0-unstable-2024-03-19";

        src = pkgs.fetchFromGitHub {
          owner = "ICS-MU";
          repo = "pam_oauth2_device";
          rev = "03efb8176afef8e962f97492da6221c579020972";
          hash = "sha256-up21k9IsGk/olcKfu/o6cy/HZiAG/CL3Qm2pZE/foZ4=";
        };

        buildInputs = [
          pkgs.pam
          pkgs.curl
          pkgs.openldap
        ];

        # The bundled Makefile hardcodes an install layout under lib64/security;
        # install the one artifact ourselves into the conventional lib/security.
        # We deliberately do NOT install config_template.json — the live config
        # (which carries the OAuth client secret) is rendered at runtime by the
        # OpenBao agent into /etc/pam_oauth2_device/config.json.
        installPhase = ''
          runHook preInstall
          install -Dm0755 pam_oauth2_device.so "$out/lib/security/pam_oauth2_device.so"
          runHook postInstall
        '';

        meta = {
          description = "PAM module for OAuth2 device-flow login (STFC/IRIS fork)";
          homepage = "https://github.com/ICS-MU/pam_oauth2_device";
          license = lib.licenses.asl20;
          platforms = lib.platforms.linux;
        };
      };
    };
}
