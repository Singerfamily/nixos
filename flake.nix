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

  outputs = { self, nixpkgs, home-manager, lanzaboote, vscode-server , ...} @ inputs:
    let
      lib = nixpkgs.lib;
    in
    with myLib; {
      nixosConfigurations = {
        thinkpad-p53 = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit self inputs; };
          modules = [ 
            ./hosts/thinkpad-p53/configuration.nix
            ./home/esinger.nix
            
            home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
              }

            ./nixos
            ./nixos/optional/fingerprint.nix

            vscode-server.nixosModules.default
            ({ config, pkgs, ... }: {
              services.vscode-server.enable = true;
            })

            lanzaboote.nixosModules.lanzaboote
          ];
        };
      };
    };
}
