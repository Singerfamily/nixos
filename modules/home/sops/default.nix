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
  # imports = with inputs; [ sops-nix.homeManagerModules.sops ];

  # options.snowfall.sops = {
  #   # Whether to decrypt and use the Age key from lib/secrets.yaml.
  #   inheritKeyFile = mkOption {
  #     type = with types; bool;
  #     default = false;
  #   };
  # };

  # config = mkIf config.snowfall.sops.inheritKeyFile {
  #   # Set up sops-nix and decrypt the age key.
  #   sops = {
  #     # age = config.sops.secrets."keys/age".path;
  #     defaultSopsFile = ../../../secrets/secrets.yaml;
  #       defaultSopsFormat = "yaml";
  #       # secrets."keys/age".path = mkIf config.snowfall.sops.inheritKeyFile keyFile;
  #     };
  #   };
}
