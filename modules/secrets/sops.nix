{
  inputs,
  ...
}:
{
  flake-file.inputs.sops-nix.url = "github:Mic92/sops-nix";

  # Bootstrap / recovery secrets ONLY. Everything else (runtime service
  # secrets, user auth, host SSH certs) lives off-device in OpenBao + Authentik
  # — see modules/aspects/services/openbao-agent.nix and modules/aspects/auth/.
  #
  # sops/bootstrap.yaml must contain:
  #   passwords:
  #     root: <hashed password>
  #     recovery: <hashed password>   # add via `sops modules/secrets/sops/bootstrap.yaml`
  den.aspects.sops = {
    nixos =
      { config, ... }:
      {
        imports = [ inputs.sops-nix.nixosModules.sops ];

        sops = {
          defaultSopsFile = ./sops/bootstrap.yaml;
          age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

          secrets = {
            "passwords/root".neededForUsers = true;
            "passwords/recovery".neededForUsers = true;
          };
        };

        users.users.root.hashedPasswordFile = config.sops.secrets."passwords/root".path;
      };
  };
}
