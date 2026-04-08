{ den, ... }:
{
  den.aspects.claude-code = {
    includes = with den.aspects; [
      nixos-mcp
    ];

    nixos =
      { pkgs, ... }:
      {
      };
    homeManager = {
      programs.claude-code = {
        enable = true;
        enableMcpIntegration = true;

        skillsDir = builtins.readDir ./skills;
      };
    };
  };
}
