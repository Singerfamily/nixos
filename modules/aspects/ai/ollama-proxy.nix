_: {
  den.aspects.ollama-proxy.nixos =
    { config, lib, ... }:
    let
      cfg = config.den.ollamaProxy;
    in
    {
      options.den.ollamaProxy = {
        enable = lib.mkEnableOption "authenticated Caddy reverse proxy in front of ollama";
        port = lib.mkOption {
          type = lib.types.port;
          default = 11435;
          description = "Port the authenticated ollama proxy listens on (all interfaces).";
        };
        upstream = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1:11434";
          description = "Address of the local ollama server to proxy to.";
        };
        secret = lib.mkOption {
          type = lib.types.str;
          default = "ollama/api-key";
          description = "Name of the sops secret holding the Bearer API key. The consuming host must declare this secret.";
        };
      };

      config = lib.mkIf cfg.enable {
        # Render KEY=value env file at runtime so the token never lands in the store.
        sops.templates."ollama-proxy.env".content = ''
          OLLAMA_API_KEY=${config.sops.placeholder.${cfg.secret}}
        '';

        services.caddy = {
          enable = true;
          virtualHosts.":${toString cfg.port}".extraConfig = ''
            @authorized header Authorization "Bearer {env.OLLAMA_API_KEY}"
            handle @authorized {
              reverse_proxy ${cfg.upstream}
            }
            handle {
              respond "Unauthorized" 401
            }
          '';
        };

        systemd.services.caddy.serviceConfig.EnvironmentFile =
          config.sops.templates."ollama-proxy.env".path;

        networking.firewall.allowedTCPPorts = [ cfg.port ];
      };
    };
}
