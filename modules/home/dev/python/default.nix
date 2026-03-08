# INFO: Python Home-manager module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.dev.python = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config =
    let
      inherit (config.snowfall.dev.python)
        enable
        ;
    in
    mkIf enable {
      home.packages = with pkgs; [
        # Python itself (black included here to avoid collision with standalone black)
        (python313.withPackages (
          ps: with ps; [
            python-lsp-server
            black
          ]
        ))

        # jetbrains.pycharm-community

        # LSP servers, formatters and linters
        pyright
        ruff
        # ruff-lsp

        # An extremely fast Python package installer and resolver, written in Rust.
        # (A replacement for pip, which does not work as expected on NixOS)
        uv
      ];
    };
}
