{
  description = "My Nix Config";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , ...
    } @ inputs:
    {
      nixosConfigurations = {
        # Personal laptop
        thinkpad-p53 = lib.nixosSystem {
          modules = [ ./hosts/thinkpad-p53 ];
          specialArgs = { inherit inputs outputs; };
        };
      };

      # homeConfigurations = {
      #   # Laptops
      #   thinkpad-p53 = lib.homeManagerConfiguration {
      #     modules = [ ./hosts/thinkpad-p53/home.nix ];
      #     pkgs = nixpkgs.legacyPackages.x86_64-linux;
      #     extraSpecialArgs = { inherit inputs outputs; };
      #   };
      # };
    };
}
