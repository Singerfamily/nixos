{
  description = "NixOS Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Hardware Configuration
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland
    # hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    # pyprland.url = "github:hyprland-community/pyprland";
    # hyprland-plugins = {
    #   url = "github:hyprwm/hyprland-plugins";
    #   inputs.hyprland.follows = "hyprland";
    # };

    # Stylix
    stylix.url = "github:danth/stylix";

    # VSCode Server
    vscode-server.url = "github:nix-community/nixos-vscode-server";

    # Secure Boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { 
    self,
    nixpkgs,
    home-manager,
    lanzaboote,
    vscode-server,
    stylix,
    nixos-hardware,
    ... 
  } @ inputs:
    let
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        thinkpad-p53 = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };

          modules = [
            stylix.nixosModules.stylix
            lanzaboote.nixosModules.lanzaboote
            ./hosts/thinkpad-p53/configuration.nix
            ./home/esinger

            ./modules

            nixos-hardware.nixosModules.lenovo-thinkpad-p53

            {
              nvidia.prime = true;
            }

            home-manager.nixosModules.home-manager {
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;

              home-manager.backupFileExtension = "backup";
              home-manager.users.esinger = import ./home/esinger/home.nix;

              home-manager.extraSpecialArgs = {inherit inputs;};
            }
          ];
        };
      };
    };
}
