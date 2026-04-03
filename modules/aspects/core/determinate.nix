{
  den,
  inputs,
  ...
}:
{
  # Sops secrets management - NixOS level (host secrets + root password)
  den.aspects.determinate = {
    nixos =
      { lib, config, ... }:
      {
        imports = [ inputs.determinate.nixosModules.default ];
      };
  };
}
