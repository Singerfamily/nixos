{ inputs, den, ... }:
{
  imports = [
    (inputs.flake-file.flakeModules.dendritic or { })
    (inputs.den.flakeModules.dendritic or { })
  ];

  # flake.den = den;

  # Only foundational inputs live here. Anything aspect-specific belongs
  # in the aspect that consumes it (e.g. plasma-manager in
  # desktop/plasma/core.nix, sops-nix in services/system/sops.nix).
  flake-file.inputs = {
    den.url = "github:denful/den";
    flake-file.url = "github:vic/flake-file";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
