{
  description = "NixOS Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "git+https://github.com/NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";

    # hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    # pyprland.url = "github:hyprland-community/pyprland";
    # hyprland-plugins = {
    #   url = "github:hyprwm/hyprland-plugins";
    #   inputs.hyprland.follows = "hyprland";
    # };

    stylix.url = "github:danth/stylix";

    vscode-server.url = "github:nix-community/nixos-vscode-server";

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };
  };

  outputs = { 
    self,
    nixpkgs,
    ... 
  } @ inputs:
    let
      mkSystem = import ./lib/mkSystem.nix {
        inherit nixpkgs inputs;
      };
    in {
      nixosConfigurations = {
        thinkpad-p53 = mkSystem "thinkpad-p53" {
          user = "esinger";

          extraModules = [
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p53
          ];
        };
      };
    };
}
