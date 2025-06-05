{
  description = "A very basic flake";

  inputs = {
    # SECTION: Core inputs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SECTION: Nix libraries.
    # Nix flake framework.
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Standalone library for the Nix language.
    nix-std.url = "github:chessai/nix-std";

    # Atomic secret provisioning for NixOS.
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Persistent state on systems with ephemeral root storage.
    impermanence.url = "github:nix-community/impermanence";

    # Manage KDE Plasma settings declaratively.
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Collection of image builders.
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative disk partitioning and formatting using Nix.
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Generate infrastructure and network diagrams directly from your NixOS configurations.
    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SECTION: Hardware.
    # Lanzaboote, UEFI secure boot for NixOS.
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS modules covering hardware quirks.
    hardware.url = "github:nixos/nixos-hardware";
  };

  outputs =
    inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      # Snowfall Lib configuration.
      snowfall = {
        namespace = "snowfall";
      };

      channels-config = {
        allowUnfree = true;
        permittedInsecurePackages = [ ];
      };

      # Global NixOS modules.
      systems.modules.nixos = with inputs; [
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        impermanence.nixosModules.impermanence
        lanzaboote.nixosModules.lanzaboote
        disko.nixosModules.disko
        # nix-topology.nixosModules.default
      ];

      # Overlays for Nixpkgs.
      overlays = with inputs; [
      ];

      templates = {
      };

      alias = {
      };

      # NOTE: An example for future self.
      # outputs-builder = channels: {
      #     topology = import inputs.nix-topology {
      #         pkgs = channels.nixpkgs;
      #         modules = [
      #             { inherit (outputs) nixosConfigurations; }
      #         ];
      #     };
      # };
    };
}
