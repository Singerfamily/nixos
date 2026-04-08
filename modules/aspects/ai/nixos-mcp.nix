{
  den,
  inputs,
  system,
  ...
}:
{
  den.aspects.nixos-mcp = {
    nixos =
      { pkgs, ... }:
      {
        imports = [
          inputs.nix-agent.nixosModules.default
        ];

        environment.systemPackages = with pkgs; [
          mcp-nixos
          inputs.nix-agent.packages.${system}.default
        ];
      };
    homeManager =
      { pkgs, ... }:
      {
        programs.mcp = {
          enable = true;

          servers = {
            nixos = {
              command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
              args = [ ];
            };

            nix-agent = {
              command = "nix-agent";
              args = [ ];
            };
          };
        };
      };
  };

  flake-file.inputs = {
    nix-agent.url = "github:JEFF7712/nix-agent";
  };
}
