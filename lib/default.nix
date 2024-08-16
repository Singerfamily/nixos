{ self
, inputs
, stateVersion
, ...
}:

let
  homeConfiguration = "${self}/home";
  hostConfiguration = "${self}/hosts";
  homeModules       = "${homeConfiguration}/modules";
  generalModules    = "${self}/modules";

  libx = import ./default.nix { inherit self inputs stateVersion; };
  outputs = inputs.self.outputs;
in {

  # ========================== Buildables ========================== #

  # Helper function for generating home-manager configs
  mkHome = { username ? "esinger", hostname ? "nixos", isWorkstation ? false, platform ? "x86_64-linux" }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${platform};
      extraSpecialArgs = {
        inherit inputs self homeModules generalModules platform username hostname stateVersion isWorkstation;
      };

      modules = [
        "${homeConfiguration}"
      ];
    };

  # Helper function for generating host configs
  mkHost = { hostname ? "nixos", username ? "esinger", isWorkstation ? false, platform ? "x86_64-linux" }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs self homeModules generalModules hostname username platform stateVersion isWorkstation libx outputs;
      };

      modules = [
        inputs.home-manager.nixosModules.home-manager
        "${hostConfiguration}"
        "${homeConfiguration}"
      ];
    };

  # =========================== Helpers ============================ #

  filesIn = dir: (map (fname: dir + "/${fname}")
    (builtins.attrNames (builtins.readDir dir)));

  dirsIn = dir:
    inputs.nixpkgs.lib.filterAttrs (name: value: value == "directory")
    (builtins.readDir dir);

  fileNameOf = path: (builtins.head (builtins.split "\\." (baseNameOf path)));

  isDir = path: builtins.pathExists (path + "/.");

  autoImports = path:
        # check if the path is a directory or a file
        if libx.isDir path then
          # it's a directory, so the set of overlays from the directory, ordered lexicographically
          let content = builtins.readDir path; in
          map (n: import (path + ("/" + n)))
            (builtins.filter
              (n:
                (builtins.match ".*\\.nix" n != null &&
                 # ignore Emacs lock files (.#foo.nix)
                 builtins.match "\\.#.*" n == null) ||
                builtins.pathExists (path + ("/" + n + "/default.nix")))
              (builtins.attrNames content))
        else
          # it's a file, so the result is the contents of the file itself
          import path;

  # ============================ Shell ============================= #
  
  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "i686-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
}
