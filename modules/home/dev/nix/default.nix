# INFO: Nix Home-manager module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.dev.nix = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config =
    let
      inherit (config.snowfall.dev.nix)
        enable
        ;
    in
    mkIf enable {
      home.packages = with pkgs; [
        nixd # Nix language server for IDEs.
        nixfmt-rfc-style # Nix formatter that follows RFC style.
        statix # Lints and suggestions for the nix programming language.
        deadnix # Find and remove unused code in .nix source files.
      ];
    };
}