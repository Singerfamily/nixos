{
  den,
  inputs,
  ...
}:
{
  den.aspects.determinate = {
    nixos =
      { lib, config, ... }:
      {
        imports = [ inputs.determinate.nixosModules.default ];
      };
  };

  flake-file.inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  };
}
