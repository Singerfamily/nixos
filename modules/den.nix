{
  inputs,
  den,
  ...
}:
{
  imports = [
    inputs.den.flakeModule
  ];

  config._module.args.__findFile = den.lib.__findFile;
}