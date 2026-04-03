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
}
