# OIDC device-code login — an OPT-IN alternative to the LDAP/SSSD auth path.
#
# This wires the pam_oauth2_device module (see modules/packages/pam-oauth2-device.nix)
# into PAM so a user can authenticate by approving an OAuth2 Device Authorization
# Grant on a second device (phone/laptop browser) instead of typing a password.
# At the login prompt the module prints a verification URL + user code (and a QR
# code); once the user approves in Authentik, the module reads the userinfo
# `preferred_username` and checks it against `userMap` to decide which local
# account the login may proceed as.
#
# This does NOT replace LDAP. SSSD still provides NSS identity (uid/gid/home) and
# remains the default auth. The PAM rule is added `sufficient` and ahead of the
# password path, so: device-code succeeds -> in; user aborts or it can't run
# (e.g. config not yet rendered) -> it falls through to the normal SSSD/password
# path. Including this aspect grants the *capability*; a host still has to expose
# it (for sshd that means enabling keyboard-interactive — see the nebula host).
#
# Scoped to sshd by default, NOT the graphical greeter: SDDM does
# `auth substack login`, so putting this on the `login` service would surface
# the device-code prompt at the greeter's password field. Desktop graphical
# login therefore uses the LDAP/Authentik password (cached offline by SSSD);
# device-code is the SSH/second-device path. See the `services` option.
#
# Not part of profile-managed. Add `oidc-login` to a host's aspect includes.
#
# Runtime prerequisites (not provisioned here — fail-safe if absent):
#   1. An Authentik OAuth2/OpenID provider+application with the Device Code flow
#      enabled, scopes openid+profile.
#   2. An OpenBao KV secret at secret/data/authentik/oidc-pam (nixos namespace)
#      with fields `client_id` and `client_secret`. The OpenBao agent renders
#      these into /etc/pam_oauth2_device/config.json at runtime, so the client
#      secret never enters the Nix store.
{
  inputs,
  ...
}:
{
  den.aspects.oidc-login = {
    nixos =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      let
        cfg = config.oidcLogin;
        pkg = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.pam_oauth2_device;
        configPath = "/etc/pam_oauth2_device/config.json";

        # The non-secret config, with consul-template placeholders where the
        # OAuth client credentials get substituted by the OpenBao agent. The
        # whole document is emitted inside a `with secret` block below.
        configJson = builtins.toJSON {
          oauth = {
            client = {
              id = "{{ .Data.data.client_id }}";
              secret = "{{ .Data.data.client_secret }}";
            };
            inherit (cfg) scope;
            device_endpoint = "${cfg.baseUrl}/application/o/device/";
            token_endpoint = "${cfg.baseUrl}/application/o/token/";
            userinfo_endpoint = "${cfg.baseUrl}/application/o/userinfo/";
            username_attribute = cfg.usernameAttribute;
            local_username_suffix = "";
          };
          # The module's libcurl runs in sshd's PAM context with no
          # SSL_CERT_FILE/CURL_CA_BUNDLE in the environment, so it can't verify
          # Authentik's cert and every device request fails with "unable to get
          # local issuer certificate". Point it at the system CA bundle.
          tls.ca_bundle = cfg.caBundle;
          # Unicode QR at medium error-correction so a phone can scan the prompt.
          qr.error_correction_level = 2;
          # remote (preferred_username) -> [ permitted local accounts ].
          users = cfg.userMap;
        };
      in
      {
        options.oidcLogin = {
          baseUrl = lib.mkOption {
            type = lib.types.str;
            default = "https://auth.singerfamily.ca";
            description = "Authentik base URL; the OIDC device/token/userinfo endpoints hang off /application/o/.";
          };

          scope = lib.mkOption {
            type = lib.types.str;
            default = "openid profile";
            description = "OAuth scopes requested. `profile` is needed for the username_attribute claim.";
          };

          usernameAttribute = lib.mkOption {
            type = lib.types.str;
            default = "preferred_username";
            description = "userinfo claim used as the remote username matched against userMap.";
          };

          caBundle = lib.mkOption {
            type = lib.types.str;
            default = "/etc/ssl/certs/ca-certificates.crt";
            description = "CA bundle the module's curl uses to verify the IdP TLS cert (PAM context has no SSL_CERT_FILE).";
          };

          userMap = lib.mkOption {
            type = lib.types.attrsOf (lib.types.listOf lib.types.str);
            default = {
              eric = [ "eric" ];
              clint = [ "clint" ];
            };
            example = {
              "eric" = [ "eric" ];
            };
            description = ''
              Map of Authentik `preferred_username` -> the local accounts that
              remote identity is allowed to log in as. A login as local user
              <l> succeeds only if the authenticated remote id lists <l>.
            '';
          };

          services = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "sshd" ];
            description = ''
              PAM services to add the device-code auth rule to. Defaults to sshd
              only: device-code is a remote/second-device flow, and the SDDM
              greeter delegates to the `login` service via `auth substack login`,
              so adding `login` would drag the device-code prompt into the
              graphical greeter (a single password field that can't render the
              URL/QR or wait on async approval). Add `login` only on headless
              hosts with no graphical greeter if you want console device-code.
            '';
          };
        };

        config = {
          # Render the live config (with the client secret) at runtime. Lives in
          # /etc (persistent) so a login still works across a reboot while
          # OpenBao is down. error_on_missing_key keeps the agent from crashing
          # if the secret isn't present yet — the file just won't render, the
          # PAM module errors, and `sufficient` falls through to SSSD.
          systemd.tmpfiles.rules = [ "d /etc/pam_oauth2_device 0700 root root -" ];

          openbao.extraTemplates = [
            {
              destination = configPath;
              perms = "0600";
              error_on_missing_key = false;
              contents = ''{{- with secret "secret/data/authentik/oidc-pam" -}}${configJson}{{- end -}}'';
            }
          ];

          # Add the module ahead of the password path on each selected service.
          # `sufficient`: success ends auth; failure/abort falls through to the
          # existing SSSD/unix rules, so LDAP login keeps working untouched.
          security.pam.services = lib.genAttrs cfg.services (_: {
            rules.auth.oauth2 = {
              control = "sufficient";
              modulePath = "${pkg}/lib/security/pam_oauth2_device.so";
              args = [ configPath ];
              order = 11000;
            };
          });
        };
      };
  };
}
