{
  inputs,
  den,
  lib,
  ...
}:
{
  flake-file.inputs.den.url = lib.mkDefault "github:denful/den";

  imports = [ inputs.den.flakeModule ];

  den.schema.user = {
    includes = [
      den.batteries.mutual-provider
      den.batteries.host-aspects
    ];
    classes = lib.mkDefault [ "homeManager" ];
  };

  # https://den.denful.dev/reference/batteries
  den.default.includes = with den.batteries; [
    define-user
    mutual-provider
    inputs' # System scoped inputs
    self' # System scoped self
  ];

  # flake.den = den; # remove after debugging
}
