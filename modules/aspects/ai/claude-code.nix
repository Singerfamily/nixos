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
        ];
      };
    homeManager =
      { pkgs, ... }:
      {
        programs.claude-code = {
          enable = true;
          enableMcpIntegration = true;

          skills = {
            nix-agent = ./skills/nix-agent;
          };

          skillsDir = builtins.readDir ./skills;

          settings = {
            hooks = {
              PostToolUse = [
                {
                  hooks = [
                    {
                      command = "nix fmt $(${pkgs.jq}/bin/jq -r '.tool_input.file_path' &lt;&lt;&lt; '$CLAUDE_TOOL_INPUT')";
                      type = "command";
                    }
                  ];
                  matcher = "Edit|MultiEdit|Write";
                }
              ];
              PreToolUse = [
                {
                  hooks = [
                    {
                      command = "echo 'Running command: $CLAUDE_TOOL_INPUT'";
                      type = "command";
                    }
                  ];
                  matcher = "Bash";
                }
              ];
            };

            autoMemoryEnabled = true;
            autoDreamEnabled = true;

            includeCoAuthoredBy = false;

            model = "opus";

            permissions = {
              additionalDirectories = [
                "../docs/"
              ];
              allow = [
                "Bash(git diff:*)"
                "Edit"
                "Bash(grep)"
              ];
              ask = [
                "Bash(git push:*)"
              ];
              defaultMode = "acceptEdits";
              deny = [
                # "WebFetch"
                # "Bash(curl:*)"
                "Read(./.env)"
                "Read(./secrets/**)"
              ];
              disableBypassPermissionsMode = "";
            };
            statusLine = {
              command = "input=$(cat); echo \"[$(echo \"$input\" | jq -r '.model.display_name')] 📁 $(basename \"$(echo \"$input\" | jq -r '.workspace.current_dir')\")\"";
              padding = 0;
              type = "command";
            };
            theme = "dark";
          };
        };
      };
  };
}
