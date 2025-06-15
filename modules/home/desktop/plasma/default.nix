# INFO: Hyprland Home-manager module.

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

with lib;
{
  # HACK: Here, because importing in flake.nix does not work.
  imports = with inputs; [ plasma-manager.homeManagerModules.plasma-manager ];
}
