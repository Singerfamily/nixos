{ den, ... }:
{
  den.aspects.claude-code = {
    includes = with den.aspects; [
      nixos-mcp
    ];

    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          bubblewrap
          socat
          claude-code
        ];
      };

    homeManager =
      { pkgs, ... }:
      {

        programs.git.ignores = [
          ".claude/settings.local.json"
        ];

        programs.claude-code = {
          enable = true;
          enableMcpIntegration = true;

          skills = ./skills;
        };
      };
  };
}
