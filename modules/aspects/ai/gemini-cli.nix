_:
{
  den.aspects.gemini-cli = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          gemini-cli
        ];
      };

    homeManager =
      { pkgs, ... }:
      {
        # Gemini CLI reads config from ~/.gemini/settings.json
        home.file.".gemini/settings.json".text = builtins.toJSON {
          mcpServers = {
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
}
