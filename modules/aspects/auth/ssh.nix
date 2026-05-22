_: {
  # OpenSSH server, fully certificate-based — one OpenBao SSH CA signs both
  # ends:
  #   • Host certs — the host presents a cert; clients trust the CA via a
  #     `@cert-authority` known_hosts line instead of pinning per-host keys.
  #     The initial cert is injected at install time alongside the host key
  #     (see scripts/deploy.sh); the OpenBao agent re-signs it before expiry
  #     and reloads sshd.
  #   • User certs — sshd trusts the same CA via `TrustedUserCAKeys`, so users
  #     log in with a short-lived cert from `scripts/ssh-user-cert.sh` instead
  #     of a password. Password auth is disabled.
  #
  # The CA lives in the flake's `nixos` OpenBao namespace
  # (see scripts/openbao-bootstrap.sh). Its public key is not secret.
  den.aspects.ssh = {
    nixos =
      { pkgs, ... }:
      let
        openbaoSshCa = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKIEB6G2xmiF6bhn5fAWhHNVCzMi4N7DojaWZ2XOrQpV";
      in
      {
        # CA public key on disk so sshd can trust user certs signed by it.
        environment.etc."ssh/openbao-ca.pub".text = "${openbaoSshCa}\n";

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
      };
  };
}
