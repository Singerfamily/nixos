{
  inputs,
  ...
}:
{
  flake-file.inputs.sops-nix.url = "github:Mic92/sops-nix";

  # Sops secrets management - NixOS level (host secrets + root password + bootstrap)
  den.aspects.sops =
    let
      secretsPath = ./sops;
    in
    {
      nixos =
        { config, ... }:
        {
          imports = [ inputs.sops-nix.nixosModules.sops ];
          sops = {
            # Default to common.yaml (accessible to all hosts).
            # Host-specific secrets should override sopsFile per-secret.
            defaultSopsFile = secretsPath + "/common.yaml";
            age.sshKeyPaths = [
              "/etc/ssh/ssh_host_ed25519_key"
            ];
          };
        };

      # # Home-manager: sops for user secrets (ssh keys, age key)
      # homeManager =
      #   { config, ... }:
      #   {
      #     imports = [ inputs.sops-nix.homeManagerModules.sops ];
      #     sops = {
      #       defaultSopsFormat = "yaml";
      #       defaultSopsFile = secretsPath + "/users/${config.home.username}.yaml";
      #       age.sshKeyPaths = [
      #         "/etc/ssh/ssh_host_ed25519_key"
      #         "${config.home.homeDirectory}/.ssh/id_ed25519"
      #         "${config.home.homeDirectory}/.ssh/id_ed25519.bak"
      #       ];
      #     };
      #   };
    };
}
