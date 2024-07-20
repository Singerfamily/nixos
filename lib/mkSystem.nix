{inputs, ...}:

hostName: 

with inputs;
with nixpkgs;

let 
  helpers = import ./helpers.nix {inherit inputs;};

  userName = "esinger";

  # The config files for this system.
  hostConfig = ../hosts/${hostName}/configuration.nix;
  userConfig = ../users/${userName};
  userHMConfig = ../users/${userName}/home.nix;
in lib.nixosSystem rec {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };

  modules = [
    ../modules

    hostConfig
    userConfig

    nix-flatpak.nixosModules.nix-flatpak
    lanzaboote.nixosModules.lanzaboote
    vscode-server.nixosModules.default {services.vscode-server.enable = true;}

    home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${userName} = import userHMConfig {
        inherit inputs;
      };

      home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];

      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = {inherit inputs;};
    }

    {
      networking.hostName = "${hostName}";
    }
  ];
}