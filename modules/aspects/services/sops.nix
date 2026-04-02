{ den, inputs, ... }:
{
  # Sops secrets management - NixOS level (host secrets + root password)
  den.aspects.sops = {
    nixos =
      { lib, config, ... }:
      {
        imports = [ inputs.sops-nix.nixosModules.sops ];
        sops = {
          defaultSopsFile = lib.mkDefault ../../secrets/secrets.yaml;
          age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
          secrets.root-password = {
            neededForUsers = true;
          };
        };
        users.users.root.hashedPasswordFile = lib.mkDefault config.sops.secrets.root-password.path;
      };

    # Home-manager: sops for user secrets (ssh keys, age key)
    homeManager =
      { lib, config, ... }:
      {
        imports = [ inputs.sops-nix.homeManagerModules.sops ];
        sops = {
          age.sshKeyPaths = [
            "/etc/ssh/ssh_host_ed25519_key"
            "${config.home.homeDirectory}/.ssh/id_ed25519"
          ];
        };
      };
  };
}
