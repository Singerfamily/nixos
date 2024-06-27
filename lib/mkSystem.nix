{nixpks, inputs, ...}: 
name: {
  system,
  user,
  modules,
}:

let 
  # The config files for this system.
  hostConfig = ../hosts/${system}/configuration.nix;
  userConfig = ../home/${user};
  userHMConfig = ../home/${user}/home.nix;

  lib = nixpks.lib;
in lib.nixosSystem rec {
  inherit system;
  specialArgs = { inherit inputs system; };

  modules = [
    modules
    ../modules

    hostConfig
    userConfig
    inputs.home-manager.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = import userHMConfig {
        inputs = inputs;
      };

      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = {inherit inputs;};
    }

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = {
        system = system;
        systemName = name;
        user = user;
        inputs = inputs;
      };
    }
  ];
}