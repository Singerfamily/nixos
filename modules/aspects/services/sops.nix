{
  den,
  inputs,
  ...
}:
{
  # Sops secrets management - NixOS level (host secrets + root password)
  den.aspects.sops =
    let
      secretsPath = ../../../secrets;
    in
    {
      nixos =
        { lib, config, ... }:
        {
          imports = [ inputs.sops-nix.nixosModules.sops ];
          sops = {
            defaultSopsFile = lib.mkDefault (secretsPath + "/hosts/${config.networking.hostName}.yaml");
            age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
            secrets."passwords/root" = {
              neededForUsers = true;
            };
          };
          users.users.root.hashedPasswordFile = lib.mkDefault config.sops.secrets."passwords/root".path;
        };

      # Home-manager: sops for user secrets (ssh keys, age key)
      homeManager =
        { lib, config, ... }:
        {
          imports = [ inputs.sops-nix.homeManagerModules.sops ];
          sops = {
            defaultSopsFile = lib.mkDefault (secretsPath + "/users/${config.home.username}.yaml");
            age.sshKeyPaths = [
              "/etc/ssh/ssh_host_ed25519_key"
              "${config.home.homeDirectory}/.ssh/id_ed25519"
              "${config.home.homeDirectory}/.ssh/id_ed25519.bak"
            ];
          };
        };
    };
}
