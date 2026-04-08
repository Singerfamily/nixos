{ den, inputs, ... }:
{
  # AI CLI tools aspect
  den.aspects.ai-tools.nixos =
    { pkgs, ... }:
    {


      environment.systemPackages = with pkgs; [
        # AI coding agents
        claude-code
        opencode
        ollama-rocm
        # aider-chat
        gemini-cli

        # Tools AI agents depend on
        jq # JSON processing
        yq-go # YAML processing
        sqlite # Lightweight DB for agent state
        watchexec # File watcher for watch modes
        inotify-tools # inotifywait for file change detection
        bc # Calculator for timestamp comparisons
        entr # Run commands on file change
        difftastic # Structural diff for better code diffs
        httpie # Human-friendly HTTP client
        curl # URL transfer tool
        wget # Network downloader

        # Language servers (used by agents for code intelligence)
        nil # Nix LSP
        typescript-language-server # TypeScript LSP
        omnisharp-roslyn # C# LSP
        pyright # Python type checker / LSP

        # Security & code quality
        trivy # Container/code vulnerability scanner
        hadolint # Dockerfile linter
        shellcheck # Shell script linter
        prettier
        eslint
      ];
    };
}
