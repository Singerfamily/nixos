{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.snowfall.ai-tools;
  userName = builtins.head (builtins.attrNames (config.home-manager.users or { }));
in

{
  options.snowfall.ai-tools = {
    enable = mkEnableOption "AI coding tools, agents, and infrastructure";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # --- AI Coding Agents ---
      claude-code            # Anthropic's Claude Code CLI
      opencode               # AI coding agent built for the terminal
      aider-chat             # Open-source AI pair programmer (supports Claude, GPT, etc.)
      gemini-cli             # Google's Gemini AI agent for the terminal

      # --- MCP & Agent Infrastructure ---
      # mcp-nixos is run via `uvx mcp-nixos` (nixpkgs build is broken on Python 3.13)
      python313Packages.uvicorn  # ASGI server (for running MCP servers)
      uv                     # Fast Python package manager (used by MCP tools)

      # --- Tools AI Agents Depend On ---
      git                    # Agents read git history, create commits, branches
      gh                     # GitHub CLI — PR creation, issue management
      tree                   # Agents use this to understand project structure
      ripgrep                # Fast code search — heavily used by agents
      fd                     # Fast file finder
      jq                     # JSON processing — agents parse API responses
      yq                     # YAML processing
      sqlite                 # Lightweight DB for agent state/context
      watchexec              # File watcher — agents trigger rebuilds
      inotify-tools          # inotifywait — file change detection for watch modes
      bc                     # Calculator — used for timestamp comparisons
      entr                   # Run commands on file change
      difftastic             # Structural diff — better code diffs for agents
      gnugrep                # grep — agents filter command output
      coreutils              # head, tail, wc, etc. — agents process text output

      # --- Container & Runtime Tools ---
      docker                 # Agents spin up containers for testing
      docker-compose

      # --- Web & API Tools ---
      httpie                 # Human-friendly HTTP client
      curl
      wget

      # --- Language Servers (used by agents for code intelligence) ---
      nodePackages.typescript-language-server
      nil                    # Nix LSP
      omnisharp-roslyn       # C# LSP
      pyright                # Python type checker / LSP

      # --- Security & Code Quality ---
      trivy                  # Container/code vulnerability scanner
      hadolint               # Dockerfile linter
      shellcheck             # Shell script linter
      nodePackages.prettier
      nodePackages.eslint
    ];

    # ── Sops secrets for OpenCode ──────────
    sops.secrets."opencode_server_username" = { };
    sops.secrets."opencode_server_password" = { };

    # ── OpenCode background server (Codex / OpenAI o3) ──────────
    # The ws tool sends prompts to this via the opencode SDK.

    # Generate opencode config for the codex instance
    system.activationScripts.opencode-servers = {
      text = ''
        mkdir -p /etc/opencode/codex

        cat > /etc/opencode/codex/opencode.json <<'OCEOF'
        { "model": "openai/gpt-5.3-codex" }
        OCEOF
      '';
    };

    # Generate ws config with the codex server profile
    system.activationScripts.ws-config = {
      deps = [ "setupSecrets" ];
      text = ''
        WS_DIR="/home/${userName}/.config/ws"
        mkdir -p "$WS_DIR"

        OC_USER="$(tr -d '\n' < ${config.sops.secrets."opencode_server_username".path} 2>/dev/null || echo opencode)"
        OC_PASS="$(tr -d '\n' < ${config.sops.secrets."opencode_server_password".path} 2>/dev/null || echo "")"

        cat > "$WS_DIR/config.json" <<WSEOF
        {
          "servers": [
            {"name": "codex", "url": "http://localhost:43102", "username": "$OC_USER", "password": "$OC_PASS", "default": true}
          ]
        }
        WSEOF

        chown -R ${userName}:users "$WS_DIR"
        chmod 600 "$WS_DIR/config.json"
      '';
    };

    # Systemd service for the codex opencode instance.
    # Runs as the user so it can access opencode's auth store.
    systemd.services.opencode-codex = let
      envScript = pkgs.writeShellScript "opencode-codex-env" ''
        # Wait for sops-nix secrets (activation may still be running after WSL restart)
        for i in $(seq 1 30); do
          [ -f ${config.sops.secrets."opencode_server_username".path} ] && break
          sleep 1
        done
        {
          echo "OPENCODE_SERVER_USERNAME=$(cat ${config.sops.secrets."opencode_server_username".path})"
          echo "OPENCODE_SERVER_PASSWORD=$(cat ${config.sops.secrets."opencode_server_password".path})"
        } > /run/opencode-codex.env
        chmod 644 /run/opencode-codex.env
      '';
    in {
      description = "OpenCode server (codex)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStartPre = "+" + envScript;
        ExecStart = "${pkgs.opencode}/bin/opencode serve --hostname 127.0.0.1 --port 43102";
        EnvironmentFile = "/run/opencode-codex.env";
        Environment = [ "OPENCODE_CONFIG=/etc/opencode/codex/opencode.json" ];
        User = userName;
        Group = "users";
        Restart = "always";
        RestartSec = "5s";
        StartLimitIntervalSec = 120;
        StartLimitBurst = 10;
        NoNewPrivileges = true;
        PrivateTmp = true;
      };
    };

    # Periodically restart the opencode server so it picks up refreshed OAuth
    # tokens from ~/.local/share/opencode/auth.json. Without this, the server
    # holds stale tokens in memory and fails with "Token refresh failed: 401".
    systemd.timers.opencode-codex-refresh = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "6h";
        OnUnitActiveSec = "6h";
        Unit = "opencode-codex-refresh.service";
      };
    };

    systemd.services.opencode-codex-refresh = {
      description = "Restart opencode-codex to pick up fresh OAuth tokens";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/run/current-system/sw/bin/systemctl restart opencode-codex.service";
      };
    };

    # Azure DevOps defaults for agents (az devops CLI reads these automatically)
    environment.variables = {
      AZURE_DEVOPS_ORG = "https://dev.azure.com/nueradev";
      AZURE_DEVOPS_PROJECT = "ProjectVicious";
    };

    # Install Claude skills from this repo into ~/.claude/skills/ on every rebuild
    system.activationScripts.install-claude-skills = let
      skillsSrc = ./skills;
    in ''
      SKILLS_DST="/home/${userName}/.claude/skills"
      mkdir -p "$SKILLS_DST"

      for skill_dir in ${skillsSrc}/*/; do
        [ -d "$skill_dir" ] || continue
        skill_name="$(basename "$skill_dir")"
        rm -rf "''${SKILLS_DST}/''${skill_name}"
        cp -a "$skill_dir" "''${SKILLS_DST}/''${skill_name}"
      done

      # Ensure scripts are executable and owned by the user
      find "$SKILLS_DST" -name '*.sh' -exec chmod +x {} +
      chown -R ${userName}:users "$SKILLS_DST"
    '';
  };
}
