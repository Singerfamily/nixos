{
  description = "NodeJS Template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let

        pkgs = nixpkgs.legacyPackages.${system};
        pname = ""; # <same as package.json name>
        version = "0.1.0";
        buildInputs = with pkgs; [
          nodejs_20
          nodePackages_latest.pnpm
        ];
        nativeBuildInputs = buildInputs;
        npmDepsHash = ""; # <prefetch-npm-deps package-lock.json>
      in
      {
        # packages = {
        #   default = pkgs.buildNpmPackage {
        #     inherit
        #       pname
        #       version
        #       buildInputs
        #       npmDepsHash
        #       nativeBuildInputs
        #       ;
        #     src = ./.;
        #     postInstall = ''
        #       mkdir -p $out/bin
        #       exe="$out/bin/${pname}"
        #       lib="$out/lib/node_modules/${pname}"
        #       cp -r ./.next $lib
        #       touch $exe
        #       chmod +x $exe
        #       echo "
        #           #!${pkgs.bash}/bin/bash
        #           cd $lib
        #           ${pkgs.nodePackages_latest.pnpm}/bin/pnpm run start" > $exe
        #     '';
        #   };
        # };

        devShells.default = pkgs.mkShell { inherit nativeBuildInputs buildInputs; };
      }
    );
}
