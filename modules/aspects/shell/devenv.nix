_:
{
  den.aspects.devenv.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        devenv
      ];
    };

  flake-file.inputs.devenv = {
    url = "github:cachix/devenv";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
