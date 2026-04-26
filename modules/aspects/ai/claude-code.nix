_:
{
  den.aspects.claude-code = {

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
      { ... }:
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
