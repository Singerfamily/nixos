_:
{
  # Caddy reverse proxy with dynamic DNS and Cloudflare integration.
  # Requires: sops secret "tokens/cloudflare" in host secrets file.
  # Enable by adding den.aspects.caddy to a host's includes.
  den.aspects.caddy.nixos =
    { config, pkgs, ... }:
    {
      sops.secrets."tokens/cloudflare" = {
        sopsFile = ../../../secrets/hosts/event-horizon.yaml;
        owner = config.services.caddy.user;
        inherit (config.services.caddy) group;
        restartUnits = [ "caddy.service" ];
      };

      services.caddy = {
        enable = true;
        package = pkgs.caddy.withPlugins {
          plugins = [
            "github.com/mholt/caddy-dynamicdns@v0.0.0-20250430031602-b846b9e8fb83"
            "github.com/caddy-dns/cloudflare@v0.2.1"
          ];
          hash = "sha256-27QeKsYk5v7dMBTaWrKsUJrf9DW1OrAMrjXhGvrchMI=";
        };

        virtualHosts."test.singerfamily.ca".extraConfig = ''
          respond "Hello, world!"
        '';

        virtualHosts."*.singerfamily.ca".extraConfig = ''
          tls {
            dns cloudflare {file.''${config.sops.secrets."tokens/cloudflare".path}}
            resolvers 1.1.1.1
          }
          handle {
            abort
          }
        '';
      };

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
      networking.hosts."127.0.0.1" = [ "test.singerfamily.ca" ];
    };
}
