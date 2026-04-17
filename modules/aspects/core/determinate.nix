{
  inputs,
  ...
}:
{
  den.aspects.determinate = {
    nixos =
      { ... }:
      {
        imports = [ inputs.determinate.nixosModules.default ];
      };
  };

  flake-file.inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  };
}
