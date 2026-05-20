{
  inputs,
  den,
  ...
}:
{
  flake-file.inputs.home-manager.url = "github:nix-community/home-manager";

  imports = [
    inputs.flake-file.flakeModules.default
  ];
}
