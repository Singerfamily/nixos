{
  inputs,
  den,
  lib,
  ...
}:
{
  flake-file.inputs.den.url = lib.mkDefault "github:denful/den";

  imports = [ inputs.den.flakeModule ];

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # https://den.denful.dev/reference/batteries
  den.default.includes = with den.batteries; [
    define-user
    os-user
    mutual-provider
    home-manager
    inputs' # System scoped inputs
    self' # System scoped self
  ];
}
