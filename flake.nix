{
  description = "NixOS Configurations";

  input = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ...}:
    let 
      lib = nixpkgs.lib;

      # ---- SYSTEM SETTINGS ---- #
      systemSettings = {
        system = "x86_64-linux"; # system arch
        hostname = "thinkpad-p53"; # hostname
      };

      # ----- USER SETTINGS ----- #
      userSettings = rec {
        username = "esinger"; # username
        name = "Eric Singer"; # name/identifier
        email = "eric@singerfamily.ca"; # email (used for certain configurations)
        dotfilesDir = "~/.dotfiles"; # absolute path of the local repo
      };
    in {
    nixosConfigurations = {
      thinkpad-p53 = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/thinkpad-p53/configuration.nix
        ];

        home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
      };
    };
  };
}