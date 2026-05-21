_:
{
  # OpenBao Agent — the on-device bridge to OpenBao (secrets.singerfamily.ca).
  #
  # Authenticates with the TLS client cert injected at install time (see
  # scripts/deploy.sh), then renders runtime secrets to disk:
  #   • SSH host certificate, re-signed by the OpenBao SSH CA
  #   • the SSSD LDAP bind password, as an /etc/sssd/conf.d snippet
  #
  # Runs via the nixpkgs `services.vault-agent` module, which is binary-agnostic:
  # `bao agent -config <json>` is CLI-compatible with `vault agent`.
  #
  # NOTE: the `settings` below are written verbatim as config.json. OpenBao's
  # config loader accepts JSON, but the `auto_auth`/`template` key shapes should
  # be verified against the OpenBao 2.x agent docs on first deploy. If the
  # module proves too constraining, the escape hatch is a hand-rolled systemd
  # unit running `${pkgs.openbao}/bin/bao agent` against an HCL file.
  den.aspects.openbao-agent = {
    nixos =
      { pkgs, ... }:
      let
        tlsDir = "/etc/openbao/tls";
      in
      {
        environment.systemPackages = [ pkgs.openbao ];

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
                contents = ''{{ with secret "ssh/sign/host" "public_key=@/etc/ssh/ssh_host_ed25519_key.pub" }}{{ .Data.signed_key }}{{ end }}'';
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
                  ldap_default_authtok = {{ with secret "kv/data/sssd/ldap-bind" }}{{ .Data.data.password }}{{ end }}
                '';
              }
            ];
          };
        };
      };
  };
}
