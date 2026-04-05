{ den, inputs, lib, ... }:
{
  den.default.nixos =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    { config, lib, ... }: {
      # Pin nix registry entries to the flake inputs
      nix.registry = lib.mkDefault (
        lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs
      );

      # Set NIX_PATH so legacy nix-shell / nix-env can find channels
      nix.nixPath = lib.mkDefault [ "/etc/nix/path" ];
      environment.etc = lib.mapAttrs' (name: value: {
        name = "nix/path/${name}";
        value.source = value.flake;
      }) config.nix.registry;
    };
}
