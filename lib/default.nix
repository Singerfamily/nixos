{
  self,
  inputs,
  stateVersion,
  ...
}:

let
  lib = inputs.nixpkgs.lib;

  libx = import ./default.nix { inherit self inputs stateVersion; };
  outputs = inputs.self.outputs;

  homeConfiguration = self + "/home";
  hostConfiguration = self + "/hosts";
  homeModules = homeConfiguration + "/modules";

  modulesDir = ../modules;
  systemModules = (libx.autoImport { path = modulesDir; });
in
{

  # ========================== Buildables ========================== #

  # Helper function for generating home-manager configs
  mkHome =
    {
      username ? "esinger",
      hostname ? "nixos",
      platform ? "x86_64-linux",
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      extraSpecialArgs = {
        inherit
          inputs
          self
          homeModules
          systemModules
          platform
          username
          hostname
          stateVersion
          ;
      };

      modules = [
        "${homeConfiguration}"
      ];
    };

  # Helper function for generating host configs
  mkHost =
    {
      hostname ? "nixos",
      username ? "esinger",
      platform ? "x86_64-linux",
    }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit
          inputs
          self
          homeModules
          systemModules
          hostname
          username
          platform
          stateVersion
          libx
          outputs
          ;
      };

      modules = [
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.home-manager.nixosModules.home-manager
        inputs.nixos-cli.nixosModules.nixos-cli

        hostConfiguration
        homeConfiguration
      ];
    };

  # =========================== Helpers ============================ #

  filesIn = dir: (map (fname: dir + "/${fname}") (builtins.attrNames (builtins.readDir dir)));

  dirsIn =
    dir: inputs.nixpkgs.lib.filterAttrs (name: value: value == "directory") (builtins.readDir dir);

  fileNameOf = path: (builtins.head (builtins.split "\\." (baseNameOf path)));

  isDir = path: builtins.pathExists (path + "/.");

  autoImport =
    {
      path ? null,
      paths ? [ ],
      include ? [ ],
      exclude ? [ ],
      recursive ? true,
    }:
    with lib;
    with fileset;
    let
      excludedFiles = filter (path: pathIsRegularFile path) exclude;
      excludedDirs = filter (path: pathIsDirectory path) exclude;
      isExcluded =
        path:
        if elem path excludedFiles then
          true
        else
          (filter (excludedDir: lib.path.hasPrefix excludedDir path) excludedDirs) != [ ];
    in
    unique (
      (filter
        (file: pathIsRegularFile file && hasSuffix ".nix" (builtins.toString file) && !isExcluded file)
        (
          concatMap (
            _path:
            if recursive then
              toList _path
            else
              mapAttrsToList (
                name: type: _path + (if type == "directory" then "/${name}/default.nix" else "/${name}")
              ) (builtins.readDir _path)
          ) (unique (if path == null then paths else [ path ] ++ paths))
        )
      )
      ++ (if recursive then concatMap (path: toList path) (unique include) else unique include)
    );

  # ============================ Shell ============================= #

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "i686-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
}
