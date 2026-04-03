{ den, ... }:
{
  # AI CLI tools aspect
  den.aspects.ai-tools.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # AI coding agents
        claude-code
        opencode
        # aider-chat
        gemini-cli

        # MCP & agent infrastructure
        uv              # Fast Python package manager (runs mcp-nixos via uvx)
        mcp-nixos       # NixOS/nix MCP server

        # Tools AI agents depend on
        jq              # JSON processing
        yq-go           # YAML processing
        sqlite          # Lightweight DB for agent state
        watchexec       # File watcher for watch modes
        inotify-tools   # inotifywait for file change detection
        bc              # Calculator for timestamp comparisons
        entr            # Run commands on file change
        difftastic      # Structural diff for better code diffs
        httpie          # Human-friendly HTTP client

        # Language servers (used by agents for code intelligence)
        nil                                        # Nix LSP
        nodePackages.typescript-language-server    # TypeScript LSP
        omnisharp-roslyn                           # C# LSP
        pyright                                    # Python type checker / LSP

        # Security & code quality
        trivy           # Container/code vulnerability scanner
        hadolint        # Dockerfile linter
        shellcheck      # Shell script linter
        nodePackages.prettier
        nodePackages.eslint
      ];
    };
}
