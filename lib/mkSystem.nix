{nixpkgs, inputs, ...}: 

host: {
  user ? "esinger",
  extraModules ? [],
  ...
}:

with nixpkgs.lib; let 
in nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };

  modules = [
    ../modules

    ../hosts/${host}/configuration.nix
    ../home/${user}

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
      home-manager.users.${user} = import ../home/${user}/home.nix {
        inherit inputs;
      };

      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = {inherit inputs;};
    }

    {
      networking.hostName = "${host}";
      time.timeZone = "America/Edmonton";
      i18n.defaultLocale = "en_CA.UTF-8";
    }

    {
      config._module.args = {
        inherit user inputs host;
      };
    }
  ] ++ extraModules;
}