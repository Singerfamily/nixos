{
  description = "NixOS Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
  };

  outputs = { self, nixpkgs, home-manager } @ inputs:
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
          ];
        };
      };
    };
}
