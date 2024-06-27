{
  description = "NixOS Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Hardware Configuration
    nixos-hardware.url = "git+https://github.com/NixOS/nixos-hardware";

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
      mkSystem = import ./lib/mkSystem.nix {
        inherit nixpkgs inputs;
      };
    in {
      nixosConfigurations = {
        thinkpad-p53 = mkSystem {
          system = "thinkpad-p53";
          user = "esinger";

          modules = [
            stylix.nixosModules.stylix
            lanzaboote.nixosModules.lanzaboote
            nixos-hardware.nixosModules.lenovo-thinkpad-p53
            {
              nvidia.prime = true;
            }
          ];
        };
        # thinkpad-p53 = lib.nixosSystem {
        #   specialArgs = { inherit inputs system; };

        #   modules = [
        #     stylix.nixosModules.stylix
        #     lanzaboote.nixosModules.lanzaboote
        #     ./hosts/thinkpad-p53/configuration.nix
        #     ./home/esinger
        #     ./modules
        #     nixos-hardware.nixosModules.lenovo-thinkpad-p53
        #     hm
        #     {
        #       nvidia.prime = true;
        #     }
        #   ];
        # };
      };
    };
}
