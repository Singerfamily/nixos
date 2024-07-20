{
  description = "NixOS Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "git+https://github.com/NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    vscode-server.url = "github:nix-community/nixos-vscode-server";

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # disko = {
    #   url = "github:nix-community/disko";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # impermanence = {
    #   url = "github:nix-community/impermanence";
    # };
  };

  outputs = { 
    self,
    nixpkgs,
    ... 
  } @ inputs: let 
    myLib = import ./lib/default.nix {inherit inputs;};
  in with myLib;{
    nixosConfigurations = {
      thinkpad-p53 = mkSystem "thinkpad-p53";
      event-horizon = mkSystem "event-horizon";
    };
  };
}