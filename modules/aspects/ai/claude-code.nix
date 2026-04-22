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

          skillsDir = ./skills;

          # settings = {
          #   hooks = {
          #     PostToolUse = [
          #       {
          #         hooks = [
          #           {
          #             command = "nix fmt $(${pkgs.jq}/bin/jq -r '.tool_input.file_path' &lt;&lt;&lt; '$CLAUDE_TOOL_INPUT')";
          #             type = "command";
          #           }
          #         ];
          #         matcher = "Edit|MultiEdit|Write";
          #       }
          #     ];
          #     PreToolUse = [
          #       {
          #         hooks = [
          #           {
          #             command = "echo 'Running command: $CLAUDE_TOOL_INPUT'";
          #             type = "command";
          #           }
          #         ];
          #         matcher = "Bash";
          #       }
          #     ];
          #   };

          #   autoMemoryEnabled = true;
          #   autoDreamEnabled = true;

          #   model = "opus";

          #   permissions = {
          #     additionalDirectories = [
          #       "../docs/"
          #     ];
          #     allow = [
          #       "Bash(git diff:*)"
          #       "Edit"
          #       "Bash(grep)"
          #     ];
          #     ask = [
          #     ];
          #     defaultMode = "acceptEdits";
          #     deny = [
          #       "Read(./.env)"
          #       "Read(./secrets/**)"
          #     ];
          #   };
          #   statusLine = {
          #     command = ./statusline.sh;
          #     type = "command";
          #   };
          #   theme = "dark";

          #   alwaysThinkingEnabled = true;

          #   voiceEnabled = true;

          #   autoConnectIde = true;
          #   autoInstallIdeExtension = true;

          #   worktree.symlinkDirectories = [
          #     "node_modules"
          #     ".cache"
          #   ];

          #   sandbox = {
          #     enabled = true;
          #     autoAllowBashIfSandboxed = true;
          #     excludedCommands = [
          #       "docker *"
          #       "podman *"
          #     ];
          #     filesystem = {
          #       denyWrite = [
          #         "/nix"
          #         "/etc"
          #         "/usr/bin"
          #         "/boot"
          #       ];

          #       denyRead = [
          #         "~/"
          #       ];

          #       allowRead = [
          #         "."
          #         "~/.claude"
          #       ];
          #     };
          #   };
          # };
        };
      };
  };
}
