{
  description = "A very basic flake";

  inputs = {
    # SECTION: Core inputs.
    nixpkgs.url = "github:mxxntype/nixpkgs/nixos-24.11";
    unstable.url = "github:mxxntype/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SECTION: Nix libraries.
    # Nix flake framework.
    snowfall-lib = {
      url = "github:mxxntype/snowfall";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Atomic secret provisioning for NixOS.
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Persistent state on systems with ephemeral root storage.
    impermanence.url = "github:nix-community/impermanence";

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
      # You must provide our flake inputs to Snowfall Lib.
      inherit inputs;

      # The `src` must be the root of the flake. See configuration
      # in the next section for information on how you can move your
      # Nix files to a separate directory.
      src = ./.;

    };
}
