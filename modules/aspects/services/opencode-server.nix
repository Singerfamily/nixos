_:
let
  # The user account that owns the opencode auth store and runs the server.
  # Currently hardcoded; if a second user needs this, lift to an option or
  # clone the aspect.
  user = "csinger";
  port = 43102;
in
{
  # OpenCode background server (Codex / OpenAI profile).
  # Runs as `user` so it can access opencode's per-user auth store.
  # Reads credentials from sops secrets `opencode_server_{username,password}`.
  den.aspects.opencode-server.nixos =
    { config, pkgs, ... }:
    let
      userHome = config.users.users.${user}.home;
      usernameSecret = config.sops.secrets."opencode_server_username".path;
      passwordSecret = config.sops.secrets."opencode_server_password".path;
    in
    {
      sops.secrets."opencode_server_username" = { };
      sops.secrets."opencode_server_password" = { };

      # Static opencode profile — the codex model selection.
      system.activationScripts.opencode-servers.text = ''
        mkdir -p /etc/opencode/codex
        cat > /etc/opencode/codex/opencode.json <<'OCEOF'
        { "model": "openai/gpt-5.3-codex" }
        OCEOF
      '';

      # Render `ws` client config that points at the local codex server.
      system.activationScripts.ws-config = {
        deps = [ "setupSecrets" ];
        text = ''
          WS_DIR="${userHome}/.config/ws"
          mkdir -p "$WS_DIR"

          OC_USER="$(tr -d '\n' < ${usernameSecret} 2>/dev/null || echo opencode)"
          OC_PASS="$(tr -d '\n' < ${passwordSecret} 2>/dev/null || echo "")"

          cat > "$WS_DIR/config.json" <<WSEOF
          {
            "servers": [
              {"name": "codex", "url": "http://localhost:${toString port}", "username": "$OC_USER", "password": "$OC_PASS", "default": true}
            ]
          }
          WSEOF

          chown -R ${user}:users "$WS_DIR"
          chmod 600 "$WS_DIR/config.json"
        '';
      };

      systemd.services.opencode-codex =
        let
          envScript = pkgs.writeShellScript "opencode-codex-env" ''
            for _ in $(seq 1 30); do
              [ -f ${usernameSecret} ] && break
              sleep 1
            done
            {
              echo "OPENCODE_SERVER_USERNAME=$(cat ${usernameSecret})"
              echo "OPENCODE_SERVER_PASSWORD=$(cat ${passwordSecret})"
            } > /run/opencode-codex.env
            chmod 644 /run/opencode-codex.env
          '';
        in
        {
          description = "OpenCode server (codex)";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          serviceConfig = {
            ExecStartPre = "+" + envScript;
            ExecStart = "${pkgs.opencode}/bin/opencode serve --hostname 127.0.0.1 --port ${toString port}";
            EnvironmentFile = "/run/opencode-codex.env";
            Environment = [ "OPENCODE_CONFIG=/etc/opencode/codex/opencode.json" ];
            User = user;
            Group = "users";
            Restart = "always";
            RestartSec = "5s";
            StartLimitIntervalSec = 120;
            StartLimitBurst = 10;
            NoNewPrivileges = true;
            PrivateTmp = true;
          };
        };

      # Restart periodically to pick up refreshed OAuth tokens.
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
    };
}
