_:
{
  # OpenSSH server. The host presents a certificate signed by the OpenBao SSH
  # CA — clients trust the CA via a `@cert-authority` known_hosts line instead
  # of pinning per-host keys.
  #
  # The initial signed cert is injected at install time alongside the host key
  # (see scripts/deploy.sh) so sshd always has a valid HostCertificate to load;
  # the OpenBao agent re-signs it before expiry and reloads sshd.
  den.aspects.ssh = {
    nixos =
      { pkgs, ... }:
      {
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = true;
            PermitRootLogin = "no";
            StreamLocalBindUnlink = "yes";
          };
          extraConfig = ''
            HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
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
        programs.ssh.startAgent = true;

        environment.systemPackages = [ pkgs.sshfs ];
      };
  };
}
