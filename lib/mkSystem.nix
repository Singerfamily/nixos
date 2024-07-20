{inputs, ...}:

hostName: 
with inputs;
with nixpkgs;

let 
  userName = "esinger";
  helpers = import ./helpers.nix {inherit inputs;};
in lib.nixosSystem rec {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };

  modules = [
    ../hosts/${hostName}/configuration.nix
    ../modules/users/${userName}

    helpers.allIn ../modules

    nix-flatpak.nixosModules.nix-flatpak
    stylix.nixosModules.stylix
    lanzaboote.nixosModules.lanzaboote
    vscode-server.nixosModules.default {services.vscode-server.enable = true;}

    home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${userName} = import ../home/${userName}/home.nix {
        inherit inputs;
      };

      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = {inherit inputs;};
    }

    {
      networking.hostName = "${hostName}";
    }
  ];
}


# {inputs, myLib, ...}: 

# with inputs;
# with nixpkgs.lib;

# hostName: 
# {
#   hostName,
#   userName ? "esinger"
# }: 

# nixosSystem rec {
#   system = "x86_64-linux";
#   specialArgs = { inherit inputs; };

#   modules = [
#     ../hosts/${hostName}/configuration.nix
#     ../modules/users/${userName}

#     # mylib.allIn ../modules

#     nix-flatpak.nixosModules.nix-flatpak
#     stylix.nixosModules.stylix
#     lanzaboote.nixosModules.lanzaboote
#     vscode-server.nixosModules.default {services.vscode-server.enable = true;}

#     home-manager.nixosModules.home-manager {
#       home-manager.useGlobalPkgs = true;
#       home-manager.useUserPackages = true;
#       home-manager.users.${userName} = import ../home/${userName}/home.nix {
#         inherit inputs;
#       };

#       home-manager.backupFileExtension = "backup";
#       home-manager.extraSpecialArgs = {inherit inputs;};
#     }

#     {
#       networking.hostName = "${hostName}";
#     }

#     {
#       config._module.args = {
#         inherit user inputs host;
#       };
#     }
#   ] ++ extraModules;
# }