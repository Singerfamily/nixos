{
  inputs,
  den,
  ...
}:
{
  flake-file.inputs.disko.url = "github:nix-community/disko/latest";

  imports = [
    inputs.disko.nixosModules.disko
  ];
}
