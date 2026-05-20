{ inputs, ... }:
{
  flake-file.inputs.determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

  den.default.nixos.imports = [ inputs.determinate.nixosModules.default ];
}
