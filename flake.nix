{
  description = "NixOS Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";

      # Optional but recommended to limit the size of your system closure.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote } @ inputs:
    let
      lib = nixpkgs.lib;
    in
    {
      nixosConfigurations = {
        thinkpad-p53 = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; }; # this is the important part
          modules = [ 
            ./hosts/thinkpad-p53/configuration.nix

             lanzaboote.nixosModules.lanzaboote

              ({ pkgs, lib, ... }: {

                environment.systemPackages = [
                  # For debugging and troubleshooting Secure Boot.
                  pkgs.sbctl
                ];

                # Lanzaboote currently replaces the systemd-boot module.
                # This setting is usually set to true in configuration.nix
                # generated at installation time. So we force it to false
                # for now.
                boot.loader.systemd-boot.enable = lib.mkForce false;

                boot.lanzaboote = {
                  enable = true;
                  pkiBundle = "/etc/secureboot";
                };
              })
          ];
        };
      };
    };
}
