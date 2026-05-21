_: {
  # OpenSSH server. The host presents a certificate signed by the OpenBao SSH
  # CA — clients trust the CA via a `@cert-authority` known_hosts line instead
  # of pinning per-host keys.
  #
  # The initial signed cert is injected at install time alongside the host key
  # (see scripts/deploy.sh) so sshd always has a valid HostCertificate to load;
  # the OpenBao agent re-signs it before expiry and reloads sshd.
  den.aspects.ssh = _: {
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

        # Trust host certificates signed by the OpenBao SSH CA, so connecting
        # to any *.singerfamily.ca host validates without per-host key pinning.
        programs.ssh = {
          startAgent = true;
          knownHosts.openbao-ssh-ca = {
            certAuthority = true;
            extraHostNames = [ "*.singerfamily.ca" ];
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOf3s08dcLS8oWm9C425yyknQi8S9NtoJ6A9mK+U+Z5I";
          };
        };

        environment.systemPackages = [ pkgs.sshfs ];
      };
  };
}
