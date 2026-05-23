{ lib, ... }:
{
  # OpenSSH server, fully certificate-based — one OpenBao SSH CA signs both
  # ends:
  #   • Host certs — the host presents a cert; clients trust the CA via a
  #     `@cert-authority` known_hosts line instead of pinning per-host keys.
  #     The initial cert is injected at install time alongside the host key
  #     (see scripts/deploy.sh); the OpenBao agent re-signs it before expiry
  #     and reloads sshd.
  #   • User certs — sshd trusts the same CA via `TrustedUserCAKeys`. The
  #     host's vault-agent (AppRole) calls `ssh/sign/user-host` to sign a
  #     short-lived cert for each user who has opted in via
  #     `openbao.sshUserCert.enable` in their home-manager config. The cert
  #     is written to `~/.ssh/id_ed25519-cert.pub` and renewed every 12h.
  #     Password auth is disabled.
  #
  # Scoping: `openbao.sshCertPrincipals` controls which users' certs are
  # accepted on a given host. It defaults to all users on the host who have
  # `sshUserCert.enable = true`. Override per-host for tighter control (e.g.
  # exclude a user from a machine they shouldn't reach).
  #
  # The CA lives in the flake's `nixos` OpenBao namespace
  # (see scripts/openbao-bootstrap.sh). Its public key is not secret.
  den.aspects.ssh = {
    nixos =
      { pkgs, config, lib, ... }:
      let
        openbaoSshCa = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKIEB6G2xmiF6bhn5fAWhHNVCzMi4N7DojaWZ2XOrQpV";

        # Home-manager users who have opted into host-agent-issued user certs.
        certUsers = lib.filterAttrs (
          _: hmCfg: hmCfg.openbao.sshUserCert.enable or false
        ) (config.home-manager.users or { });

        # /etc/ssh/authorized_principals/<user> — one file per trusted principal.
        # sshd checks this file (via AuthorizedPrincipalsFile) and only accepts
        # a cert whose principal is listed there.
        principalFiles = lib.listToAttrs (
          map (principal: {
            name = "ssh/authorized_principals/${principal}";
            value = {
              text = "${principal}\n";
              mode = "0444";
            };
          }) config.openbao.sshCertPrincipals
        );
      in
      {
        options.openbao.sshCertPrincipals = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = ''
            Usernames whose CA-signed user certs are accepted for login on this
            host. Defaults to every home-manager user with sshUserCert.enable.
            Override explicitly for tighter per-host access control.
          '';
        };

        config = {
          # Auto-derive from opted-in HM users; hosts can override.
          openbao.sshCertPrincipals = lib.mkDefault (lib.attrNames certUsers);

          environment.etc = {
            # CA public key consumed by TrustedUserCAKeys below.
            "ssh/openbao-ca.pub".text = "${openbaoSshCa}\n";
          } // principalFiles;

          services.openssh = {
            enable = true;
            settings = {
              PasswordAuthentication = false;
              PermitRootLogin = "no";
              StreamLocalBindUnlink = "yes";
            };
            extraConfig = ''
              HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
              TrustedUserCAKeys /etc/ssh/openbao-ca.pub
              ${lib.optionalString (config.openbao.sshCertPrincipals != [ ])
                "AuthorizedPrincipalsFile /etc/ssh/authorized_principals/%u"}
            '';
          };

          # Renewed certs arrive via the OpenBao agent; order sshd after it so a
          # freshly-provisioned host picks up the cert. `wants`, not `requires`:
          # an OpenBao outage must not stop sshd from coming up on the cert that
          # was injected at install time.
          systemd.services.sshd = {
            after = [ "vault-agent-openbao.service" ];
            wants = [ "vault-agent-openbao.service" ];
          };

          programs.mosh = {
            enable = true;
            withUtempter = true;
          };

          # Trust host certificates signed by the OpenBao SSH CA, so connecting
          # to any *.singerfamily.ca host validates without per-host key pinning.
          programs.ssh = {
            startAgent = true;
            knownHosts.openbao-ssh-ca = {
              certAuthority = true;
              extraHostNames = [ "*.singerfamily.ca" ];
              publicKey = openbaoSshCa;
            };
          };

          environment.systemPackages = [ pkgs.sshfs ];

          # Ensure ~/.ssh/ exists for cert delivery before vault-agent starts.
          systemd.tmpfiles.rules = lib.unique (
            lib.mapAttrsToList (username: hmCfg:
              "d ${builtins.dirOf hmCfg.openbao.sshUserCert.certFile} 0700 ${username} ${username} -"
            ) certUsers
          );

          # Vault-agent templates: sign a 12h user cert for each opted-in user
          # and write it directly to their ~/.ssh/ cert slot. The AppRole
          # credential is permitted to call ssh/sign/user-host
          # (see scripts/provision-host.sh host policy).
          # Scoping is enforced server-side by AuthorizedPrincipalsFile above —
          # a host that doesn't list a principal won't accept the cert.
          openbao.extraTemplates = lib.mapAttrsToList (username: hmCfg: {
            destination = hmCfg.openbao.sshUserCert.certFile;
            perms = "0644";
            error_on_missing_key = false;
            command = "${pkgs.coreutils}/bin/chown ${username}:${username} ${hmCfg.openbao.sshUserCert.certFile}";
            contents = ''{{ with secret "ssh/sign/user-host" (printf "public_key=%s" (file "${hmCfg.openbao.sshUserCert.publicKeyFile}")) "cert_type=user" "valid_principals=${username}" }}{{ .Data.signed_key }}{{ end }}'';
          }) certUsers;
        };
      };

    # -------------------------------------------------------------------------
    # Home-manager module: per-user opt-in for host-agent-issued SSH certs.
    # When enabled, the host's vault-agent signs this user's public key and
    # writes the cert to certFile every 12h. No user action required.
    # -------------------------------------------------------------------------
    homeManager =
      { config, lib, ... }:
      {
        options.openbao.sshUserCert = {
          enable = lib.mkEnableOption "host-agent-issued SSH user certificate";

          publicKeyFile = lib.mkOption {
            type = lib.types.str;
            default = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
            description = "Public key to sign. Must exist on the host filesystem when the agent runs.";
          };

          certFile = lib.mkOption {
            type = lib.types.str;
            default = "${config.home.homeDirectory}/.ssh/id_ed25519-cert.pub";
            description = "Where the signed cert is written. SSH picks this up automatically when it sits alongside the private key.";
          };
        };
      };
  };
}
