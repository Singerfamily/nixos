_: {
  # OpenBao Agent — the on-device bridge to OpenBao (secrets.singerfamily.ca).
  #
  # Authenticates with the TLS client cert injected at install time (see
  # scripts/deploy.sh), then renders runtime secrets to disk:
  #   • SSH host certificate, re-signed by the OpenBao SSH CA
  #   • the SSSD LDAP bind password, as an /etc/sssd/conf.d snippet
  #   • the Authentik LDAP outpost token, as a container env-file
  #
  # Runs via the nixpkgs `services.vault-agent` module, which is binary-agnostic:
  # `bao agent -config <json>` is CLI-compatible with `vault agent`.
  #
  # NOTE: the `settings` below are written verbatim as config.json. OpenBao's
  # config loader accepts JSON, but the `auto_auth`/`template` key shapes should
  # be verified against the OpenBao 2.x agent docs on first deploy. If the
  # module proves too constraining, the escape hatch is a hand-rolled systemd
  # unit running `${pkgs.openbao}/bin/bao agent` against an HCL file.
  den.aspects.openbao-agent = _: {
    nixos =
      { pkgs, config, ... }:
      let
        tlsDir = "/etc/openbao/tls";
        # Host certs are signed for this principal; the ssh/roles/host role
        # permits singerfamily.ca subdomains.
        sshPrincipal = "${config.networking.hostName}.singerfamily.ca";
      in
      {
        environment.systemPackages = [ pkgs.openbao ];

        # Ensure destination directories for template renders exist before the
        # agent starts. /run/* is tmpfs (recreated every boot); /var/lib/sssd
        # is owned by sssd's preStart but vault-agent runs first at first boot.
        systemd.tmpfiles.rules = [
          "d /run/authentik-ldap 0700 root root -"
          "d /var/lib/sssd      0711 root root -"
          "d /var/lib/sssd/conf.d 0700 root root -"
        ];

        services.vault-agent.instances.openbao = {
          package = pkgs.openbao;

          settings = {
            vault = {
              address = "https://secrets.singerfamily.ca";
              ca_cert = "${tlsDir}/ca.crt";
            };

            # Authenticate with the install-time TLS client cert. The agent
            # renews itself via the cert auth method thereafter.
            auto_auth = {
              method = {
                type = "cert";
                config = {
                  # Matches the cert role registered at auth/cert/certs/host.
                  name = "host";
                  client_cert = "${tlsDir}/client.crt";
                  client_key = "${tlsDir}/client.key";
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
              # reloaded once a fresh cert lands. The host keypair itself stays
              # locally generated; only the public key is signed.
              {
                destination = "/etc/ssh/ssh_host_ed25519_key-cert.pub";
                perms = "0644";
                error_on_missing_key = false;
                command = "${pkgs.systemd}/bin/systemctl reload sshd.service";
                contents = ''{{ with secret "ssh/sign/host" "public_key=@/etc/ssh/ssh_host_ed25519_key.pub" "cert_type=host" "valid_principals=${sshPrincipal}" }}{{ .Data.signed_key }}{{ end }}'';
              }
              # SSSD LDAP bind password, dropped into conf.d so the secret
              # never enters the Nix store. Lives in /etc (persistent), so a
              # reboot while OpenBao is down still has the last-good password.
              {
                destination = "/etc/sssd/conf.d/01-ldap-bind.conf";
                perms = "0600";
                error_on_missing_key = false;
                command = "${pkgs.systemd}/bin/systemctl try-reload-or-restart sssd.service";
                contents = ''
                  [domain/singerfamily]
                  ldap_default_authtok = {{ with secret "secret/data/sssd/ldap-bind" }}{{ .Data.data.password }}{{ end }}
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
