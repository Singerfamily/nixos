_:
{
  # Placeholder aspect — all functionality commented until nix-agent input is wired up.
  #
  # To enable:
  # 1. Add to flake-file.inputs in dendritic.nix:
  #      nix-agent.url = "github:JEFF7712/nix-agent";
  #    Then run: nix run .#write-flake
  # 2. Uncomment the nixos/homeManager bodies below.
  den.aspects.nixos-mcp = {
    nixos = { inputs, pkgs, system, ... }: {
      # imports = [ inputs.nix-agent.nixosModules.default ];
      # programs.nix-agent.enable = true;
      # environment.systemPackages = [
      #   pkgs.mcp-nixos
      #   inputs.nix-agent.packages.${system}.default
      # ];
    };
    homeManager = { pkgs, ... }: {
      # programs.mcp = {
      #   enable = true;
      #   servers = {
      #     nixos.command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
      #     nix-agent.command = "nix-agent";
      #   };
      # };
    };
  };
}
