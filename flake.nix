{
  description = "NixOS Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server.url = "github:nix-community/nixos-vscode-server";

    lanzaboote = {
      url = "github:nix-community/lanzaboote";

      # Optional but recommended to limit the size of your system closure.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, vscode-server, ... } @ inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        thinkpad-p53 = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit self inputs; };
          modules = [
            lanzaboote.nixosModules.lanzaboote
            ./hosts/thinkpad-p53/configuration.nix
            ./home/esinger

            ./modules

            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;

              home-manager.users.esinger = import ./home/esinger/home.nix;
            }
          ];
        };
      };
    };
}
