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

    # Zsh plugins
    powerlevel10k = {
      url = "github:romkatv/powerlevel10k";
      flake = false;
    };

    zsh-autosuggestions = {
      url = "github:zsh-users/zsh-autosuggestions";
      flake = false;
    };

    zsh-syntax-highlighting = {
      url = "github:zsh-users/zsh-syntax-highlighting";
      flake = false;
    };

    fzf-zsh-completions = {
      url = "github:chitoku-k/fzf-zsh-completions";
      flake = false;
    };
  };

  outputs = { self, flake-parts, ... } @ inputs:
  let
    linuxArch          = "x86_64-linux";
    linuxArmArch       = "aarch64-linux";
    darwinArch         = "aarch64-darwin";
    stateVersion       = "24.11";
    stateVersionDarwin = 4;
    libx               = import ./lib { inherit self inputs stateVersion stateVersionDarwin; };

    hosts = {
      event-horizon = { hostname = "event-horizon"; username = "esinger"; platform = linuxArch; isWorkstation = true; };
      thinkpad-p53  = { hostname = "thinkpad-p53"; username = "esinger"; platform = linuxArch; isWorkstation = true; };
    };
  in flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [
      linuxArch
      linuxArmArch
      darwinArch
    ];

    flake = {

      nixosConfigurations = inputs.nixpkgs.lib.mapAttrsToList (name: host: libx.mkHost host) hosts;

      # nixosConfigurations = {
      #   ${hosts."event-horizon".hostname} = libx.mkHost hosts."event-horizon";
      #   ${hosts."thinkpad-p53".hostname} = libx.mkHost hosts."thinkpad-p53";
      # };

      # darwinConfigurations = {
      #   ${hosts.macbox.hostname} = libx.mkHostDarwin hosts.macbox;
      # };

      templates = import "${self}/templates" { inherit self; };
    };
  };

  # outputs = { 
  #   ... 
  # } @ inputs: let 
  #   myLib = import ./lib/default.nix {inherit inputs;};
  # in with myLib;{
  #   nixosConfigurations = {
  #     thinkpad-p53 = mkSystem "thinkpad-p53";
  #     event-horizon = mkSystem "event-horizon";
  #     default = mkSystem "default";
  #   };
  # };
}