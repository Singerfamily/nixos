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
        programs.claude-code = {
          enable = true;
          enableMcpIntegration = true;

          skillsDir = ./skills;

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
              ];
              defaultMode = "acceptEdits";
              deny = [
                "Read(./.env)"
                "Read(./secrets/**)"
              ];
            };
            statusLine = {
              command = pkgs.writeTextFile {
                name = "claude-status-line";
                text =
                  let
                    jq = "${pkgs.jq}/bin/jq";
                  in
                  ''
                    #!${pkgs.bash}/bin/bash
                    # Claude Code Statusline

                    # Read all JSON data from stdin
                    input=$(${pkgs.busybox}/bin/cat)

                    # Extract Model (fallback to "unknown")
                    model=$(echo "$input" | ${jq} -r '.model.display_name // "unknown"')

                    # Extract Project Directory (prefer project_dir over current_dir)
                    dir=$(echo "$input" | ${jq} -r '.workspace.project_dir // .workspace.current_dir // ""')
                    dir_short=$(basename "$dir")

                    # Extract Context Percentage (cut handles floating point numbers like "42.5" by taking the integer part)
                    ctx=$(echo "$input" | ${jq} -r '.context_window.used_percentage // 0' | cut -d. -f1)

                    # Extract Rate Limits (use `// empty` to gracefully handle absence before first API call or for non-Pro users)
                    rl_5h=$(echo "$input" | ${jq} -r '.rate_limits.five_hour.used_percentage // empty' | cut -d. -f1)
                    rl_7d=$(echo "$input" | ${jq} -r '.rate_limits.seven_day.used_percentage // empty' | cut -d. -f1)

                    # ANSI Colors
                    CYAN="\033[36m"
                    GREEN="\033[32m"
                    DIM="\033[2m"
                    BOLD="\033[1m"
                    RST="\033[0m"

                    # Build Progress bar for context usage
                    bar_width=10
                    filled=$((ctx * bar_width / 100))
                    empty=$((bar_width - filled))

                    bar=""
                    if [ "$filled" -gt 0 ]; then
                      fill_str=$(printf "%''${filled}s")
                      bar="''${bar}''${fill_str// /▓}"
                    fi
                    if [ "$empty" -gt 0 ]; then
                      empty_str=$(printf "%''${empty}s")
                      bar="''${bar}''${empty_str// /░}"
                    fi

                    # Build Rate Limits string dynamically based on presence in JSON
                    limits_str=""
                    if [ -n "$rl_5h" ]; then
                        limits_str="''${DIM} | ''${RST}5h: ''${rl_5h}%"
                    fi
                    if [ -n "$rl_7d" ]; then
                        limits_str="''${limits_str}''${DIM} | ''${RST}7d: ''${rl_7d}%"
                    fi

                    # Fallback if rate limits aren't populated yet
                    if [ -z "$limits_str" ]; then
                        limits_str="''${DIM} | ''${RST}Limits: pending..."
                    fi

                    # Print the multi-line status output
                    echo -e "''${BOLD}''${CYAN}[''${model}]''${RST}''${DIM} | ''${RST}''${BOLD}''${dir_short}''${RST}"
                    echo -e "''${GREEN}[''${bar}] ''${ctx}%''${RST}''${limits_str}"
                  '';
                executable = true; # Makes the file executable
              };
              type = "command";
            };
            theme = "dark";

            alwaysThinkingEnabled = true;

            voiceEnabled = true;

            autoConnectIde = true;
            autoInstallIdeExtension = true;

            worktree.symlinkDirectories = [
              "node_modules"
              ".cache"
            ];

            sandbox = {
              enabled = true;
              autoAllowBashIfSandboxed = true;
              excludedCommands = [
                "docker *"
                "podman *"
              ];
              filesystem = {
                denyWrite = [
                  "/nix"
                  "/etc"
                  "/usr/bin"
                  "/boot"
                ];

                denyRead = [
                  "~/"
                ];

                allowRead = [
                  "."
                  "~/.claude"
                ];
              };
            };
          };
        };
      };
  };
}
