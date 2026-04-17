{ inputs, lib, ... }:
let
  langs = lib.pipe (builtins.readDir ./.) [
    (lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".nix" n && n != "default.nix"))
    builtins.attrNames
    (map (lib.removeSuffix ".nix"))
  ];
in
{
  imports = [
    (inputs.den.namespace "dev" false)
    # Guard: every dev.<lang> aspect auto-includes dev.common
    (
      { config, ... }:
      {
        dev = lib.genAttrs langs (_: {
          includes = [ config.dev.common ];
        });
      }
    )
  ];

  dev.common.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        typos
        graphviz
      ];
    };
}
