{nixpkgs, inputs, ...}: 

host: {
  user,
  extraModules ? [],
}:

let 
  # The config files for this system.
  hostConfig = ../hosts/${host}/configuration.nix;
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
    inputs.vscode-server.nixosModules.default {services.vscode-server.enable = true;}

    # inputs.impermanence.nixosModules.home-manager.impermanence
    # inputs.disko.nixosModules.disko

    inputs.home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      # home-manager.sharedModules = [
      #   inputs.plasma-manager.homeManagerModules.plasma-manager
      # ];
      home-manager.users.${user} = import userHMConfig {
        inherit inputs;
      };

      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = {inherit inputs;};
    }

    {
      networking.hostName = "${host}";
      networking.networkmanager.enable = true;
      time.timeZone = "America/Edmonton";
      i18n.defaultLocale = "en_CA.UTF-8";
    }

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = {
        inherit user inputs host;
      };
    }
  ] ++ extraModules;
}