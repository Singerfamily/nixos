{
  description = "A very basic flake";

  inputs = {
    # SECTION: Core inputs.
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      # url = "github:nix-community/home-manager/release-24.11";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SECTION: Nix libraries.
    # Nix flake framework.
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # VSCode server
    vscode-server.url = "github:nix-community/nixos-vscode-server";

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

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";

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
    { ... }@inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = builtins.path {
        path = ./.;
        name = "flake-src";
      };

      # Snowfall Lib configuration.
      snowfall = {
        namespace = "snowfall";
      };

      channels-config = {
        allowUnfree = true;
        permittedInsecurePackages = [ ];
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };

      # Global NixOS modules.
      systems.modules.nixos = with inputs; [
        determinate.nixosModules.default
        vscode-server.nixosModules.default
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        impermanence.nixosModules.impermanence
        lanzaboote.nixosModules.lanzaboote
        disko.nixosModules.disko
        nix-flatpak.nixosModules.nix-flatpak
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
