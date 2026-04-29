{ inputs, ... }:
{
  # TODO: Add vscode-server input to flake-file.inputs in modules/dendritic.nix:
  #   vscode-server = {
  #     url = "github:nix-community/nixos-vscode-server";
  #     inputs.nixpkgs.follows = "nixpkgs";
  #   };
  # Then run: nix run .#write-flake
  # After that, uncomment the aspect below.

  den.aspects.vscode-server.nixos =
    { ... }:
    {
      imports = [ inputs.vscode-server.nixosModules.default ];
      services.vscode-server.enable = true;
    };

  flake-file.inputs.vscode-server = {
    url = "github:nix-community/nixos-vscode-server";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
