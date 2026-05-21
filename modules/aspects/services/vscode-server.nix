{ inputs, ... }:
{
  flake-file.inputs.vscode-server.url = "github:nix-community/nixos-vscode-server";

  den.aspects.vscode-server.nixos =
    { pkgs, ... }:
    {
      imports = [ inputs.vscode-server.nixosModules.default ];
      services.vscode-server.enable = true;

      programs.nix-ld.enable = true;

      environment.systemPackages = with pkgs; [
        wget
      ];
    };
}
