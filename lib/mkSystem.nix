{nixpkgs, inputs, ...}: 

name: {
  user,
  extraModules ? [],
}:

let 
  # The config files for this system.
  hostConfig = ../hosts/${name}/configuration.nix;
  userConfig = ../home/${user};
  userHMConfig = ../home/${user}/home.nix;

  lib = nixpkgs.lib;
in lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };

  modules = [
    ../modules

    hostConfig
    userConfig

    inputs.nix-flatpak.nixosModules.nix-flatpak

    inputs.stylix.nixosModules.stylix

    inputs.lanzaboote.nixosModules.lanzaboote

    # inputs.impermanence.nixosModules.home-manager.impermanence
    # inputs.disko.nixosModules.disko

    inputs.home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = import userHMConfig {
        inherit inputs;
      };

      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = {inherit inputs;};
    }

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = {
        host = name;
        inherit user inputs;
      };
    }
  ] ++ extraModules;
}