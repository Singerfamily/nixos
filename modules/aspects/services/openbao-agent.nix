_: {
  # OpenBao Agent — the on-device bridge to OpenBao (secrets.singerfamily.ca).
  #
  # Authenticates via AppRole. role_id + secret_id are injected at install
  # time (see scripts/deploy.sh) into /etc/openbao/approle/. The agent reads
  # both, logs in, then renders runtime secrets to disk:
  #   • SSH host certificate, re-signed by the OpenBao SSH CA
  #   • the SSSD LDAP bind credentials, as an /etc/sssd/conf.d snippet
  #   • the Authentik LDAP outpost token, as a container env-file
  #
  # AppRole was chosen over the original cert-auth design because OpenBao
  # sits behind a Traefik reverse proxy that terminates TLS with a
  # centralized cert — TLS client certs can't survive termination on OSS
  # without a separate mTLS passthrough endpoint. AppRole carries no
  # transport requirement and works through any HTTPS reverse proxy.
  #
  # Runs via the nixpkgs `services.vault-agent` module, which is binary-
  # agnostic: `bao agent -config <json>` is CLI-compatible with `vault agent`.
  den.aspects.openbao-agent = {
    nixos =
      { pkgs, config, ... }:
      let
        approleDir = "/etc/openbao/approle";
        # Host certs are signed for this principal; the ssh/roles/host role
        # permits singerfamily.ca subdomains.
        sshPrincipal = "${config.networking.hostName}.singerfamily.ca";
      in
      {
        environment.systemPackages = [ pkgs.openbao ];

        # Ensure destination directories for template renders exist before
        # the agent starts. /run/* is tmpfs (recreated every boot).
        systemd.tmpfiles.rules = [
          "d /run/authentik-ldap 0700 root root -"
          "d /var/lib/sssd      0711 root root -"
          "d /var/lib/sssd/conf.d 0700 root root -"
          "d /var/lib/openbao-agent 0700 root root -"
        ];

        services.vault-agent.instances.openbao = {
          package = pkgs.openbao;

          settings = {
            # One-way TLS to OpenBao — Traefik terminates with a publicly-
            # trusted cert (Let's Encrypt). No ca_cert: rely on the system
            # CA bundle (security.pki.*). If we ever bypass Traefik and hit
            # OpenBao's internal listener directly, set ca_cert = ca.crt
            # from the install-time seed.
            vault = {
              address = "https://secrets.singerfamily.ca";
            };

            # AppRole login. role_id + secret_id are seeded by
            # scripts/deploy.sh from scripts/provision-host.sh output.
            # remove_secret_id_file_after_reading=false keeps the secret_id
            # on disk so the agent can re-login after a restart without
            # re-provisioning. If we ever rotate secret_ids on a schedule,
            # flip this to true and use a wrapped delivery flow.
            auto_auth = {
              method = {
                type = "approle";
                config = {
                  role_id_file_path = "${approleDir}/role_id";
                  secret_id_file_path = "${approleDir}/secret_id";
                  remove_secret_id_file_after_reading = false;
                };
              };
              sink = [
                {
                  type = "file";
                  config.path = "/run/vault-agent/token";
                }
              ];
            };

            template = [
              # SSH host certificate, signed by the OpenBao SSH CA. sshd is
              # reloaded once a fresh cert lands. The host keypair itself
              # stays locally generated; only the public key is signed.
              {
                destination = "/etc/ssh/ssh_host_ed25519_key-cert.pub";
                perms = "0644";
                error_on_missing_key = false;
                command = "${pkgs.systemd}/bin/systemctl reload sshd.service";
                contents = ''{{ with secret "ssh/sign/host" (printf "public_key=%s" (file "/etc/ssh/ssh_host_ed25519_key.pub")) "cert_type=host" "valid_principals=${sshPrincipal}" }}{{ .Data.signed_key }}{{ end }}'';
              }
              # SSSD LDAP bind credentials, dropped into conf.d so the secret
              # never enters the Nix store. Lives in /etc (persistent), so a
              # reboot while OpenBao is down still has the last-good password.
              # Both the bind DN and the password come from the same OpenBao
              # secret (rotating the service account is one change).
              {
                destination = "/etc/sssd/conf.d/01-ldap-bind.conf";
                perms = "0600";
                error_on_missing_key = false;
                command = "${pkgs.systemd}/bin/systemctl try-reload-or-restart sssd.service";
                contents = ''
                  {{ with secret "secret/data/authentik/ldap-service-account" }}
                  [domain/singerfamily]
                  ldap_default_bind_dn = cn={{ .Data.data.username }},ou=users,dc=ldap,dc=goauthentik,dc=io
                  ldap_default_authtok = {{ .Data.data.password }}
                  {{ end }}
                '';
              }
              # Authentik LDAP outpost token, as an env-file for the outpost
              # container (see modules/aspects/auth/authentik-ldap-outpost.nix).
              {
                destination = "/run/authentik-ldap/env";
                perms = "0600";
                error_on_missing_key = false;
                command = "${pkgs.systemd}/bin/systemctl try-restart docker-authentik-ldap.service";
                contents = ''AUTHENTIK_TOKEN={{ with secret "secret/data/authentik/ldap-outpost-token" }}{{ .Data.data.token }}{{ end }}'';
              }
            ];
          };
        };
      };
  };
}
