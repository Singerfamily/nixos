# INFO: NixOS sops-nix module.

{
  config,
  lib,
  # system,
  # hostname,
  ...
}:

with lib;
{
  config = {
    sops = {
      defaultSopsFile = ../../../secrets/hosts + "/${config.networking.hostName}.yaml";
      age = {
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    };

    # fileSystems."/etc/ssh".neededForBoot = true; # Impermanence
  };
}
