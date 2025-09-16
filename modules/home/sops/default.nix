# {...}: {}

# INFO: Home-manager sops-nix module.

{
  config,
  lib,
  inputs,
  ...
}:

with lib;
{
  # HACK: For some reason, importing it in flake.nix fails, but works here...
  imports = with inputs; [ sops-nix.homeManagerModules.sops ];

  options.snowfall.sops = {
    # Whether to decrypt and use the Age key from lib/secrets.yaml.
    # inheritKeyFile = mkOption {
    #   type = with types; bool;
    #   default = false;
    # };

    enable = mkOption {
      type = with types; bool;
      default = false;
      description = "Enable sops-nix module to manage secrets.";
    };
  };

  config = mkIf config.snowfall.sops.enable {
    # Set up sops-nix and decrypt the age key.
    sops = {
      age = {
        sshKeyPaths = [ "${home.homeDirectory}/.ssh/id_ed25519" ];
        generateKey = true;
      };
      defaultSopsFile = ../../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
    };
  };
}
