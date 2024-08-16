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


  # ============================ Shell ============================= #
  
  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "i686-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
}
