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
    enable = mkOption {
      type = with types; bool;
      default = true;
      description = "Enable sops-nix module to manage secrets.";
    };
  };

  config = mkIf config.snowfall.sops.enable {
    sops = {
      age = {
        keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
        # generateKey = true;
        sshKeyPaths = mkDefault [
          "/home/${config.home.username}/.ssh/id_ed25519"
          "/home/${config.home.username}/.ssh/id_ed25519.bak"
        ];
      };
      defaultSopsFile = ../../../secrets/users + "/${config.home.username}.yaml";
      defaultSopsFormat = "yaml";
    };
  };
}
