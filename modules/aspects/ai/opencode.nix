_:
{
  den.aspects.opencode = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          opencode
        ];
      };

    homeManager =
      { pkgs, ... }:
      {
        # OpenCode reads config from ~/.config/opencode/opencode.json
        xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
          "$schema" = "https://opencode.ai/config.json";

          mcp = {
            nixos = {
              type = "local";
              command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
              args = [ ];
            };
            nix-agent = {
              type = "local";
              command = "nix-agent";
              args = [ ];
            };
          };
        };

        # Symlink skills into OpenCode's global skills directory
        xdg.configFile."opencode/skills/nix-agent" = {
          source = ./skills/nix-agent;
          recursive = true;
        };

        # Symlink agents into OpenCode's global agents directory
        xdg.configFile."opencode/agents" = {
          source = ./agents;
          recursive = true;
        };
      };
  };
}
