{
  description = "NixOS Configurations";

  inputs = {
    # Official NixOS repo
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "git+https://github.com/NixOS/nixos-hardware";

    # NixOS community
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # disko = {
    #   url = "github:nix-community/disko";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # impermanence.url = "github:/nix-community/impermanence";
    # stylix.url = "github:danth/stylix";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    vscode-server.url = "github:nix-community/nixos-vscode-server";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Just for pretty flake.nix
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Security
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, flake-parts, ... } @ inputs:
  let
    linuxArch          = "x86_64-linux";
    linuxArmArch       = "aarch64-linux";
    darwinArch         = "aarch64-darwin";
    stateVersion       = "24.11";
    libx               = import ./lib { inherit self inputs stateVersion; };
  in flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [
      linuxArch
      linuxArmArch
      darwinArch
    ];

    flake = {

      nixosConfigurations = {
        event-horizon = libx.mkHost { hostname = "event-horizon"; };
        thinkpad-p53  = libx.mkHost { hostname = "thinkpad-p53"; };
      };

      # nixosConfigurations = {
      #   ${hosts."event-horizon".hostname} = libx.mkHost hosts."event-horizon";
      #   ${hosts."thinkpad-p53".hostname} = libx.mkHost hosts."thinkpad-p53";
      # };

      templates = import "${self}/templates" { inherit self; };
    };
  };
}