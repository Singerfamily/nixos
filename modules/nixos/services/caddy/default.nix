{
  config,
  lib,
  pkgs,
  ...
}:
let
  service = "caddy";
  cfg = config.services.${service};
in
with lib;
{
  config = mkIf cfg.enable (
    let
      inherit (config.services.caddy) user group;
      inherit (config.networking) domain;
    in
    {
      sops.secrets."tokens/cloudflare" = {
        sopsFile = ../../../../secrets/services/caddy.yaml;
        # format = "dotenv";
        owner = user;
        inherit group;
        restartUnits = [ "caddy.service" ];
      };

      services.caddy = {
        package = pkgs.caddy.withPlugins {
          # NOTE: Occasionally specify @latest and update the new versions, and the result hash.
          plugins = [
            "github.com/mholt/caddy-dynamicdns@v0.0.0-20250430031602-b846b9e8fb83"
            "github.com/caddy-dns/cloudflare@v0.2.1"
          ];

          # NOTE: Built on 6/4/2025
          hash = "sha256-27QeKsYk5v7dMBTaWrKsUJrf9DW1OrAMrjXhGvrchMI=";
        };


        virtualHosts = {
          "test.singerfamily.ca" = {
            extraConfig = ''
              respond "Hello, world!"
            '';
          };
        };

        virtualHosts."*.${domain}".extraConfig = ''
          tls {
            dns cloudflare {file.${config.sops.secrets."tokens/cloudflare".path}}
            resolvers 1.1.1.1 
          }

          # Fallback for unhandled subdomains
          handle {
            abort
          }
        '';

        # environmentFile = config.sops.secrets."env/caddy".path;

        # globalConfig = ''
        #   dynamic_dns {
        #     provider cloudflare {file.${config.sops.secrets."tokens/cloudflare".path}}
        #     domains {
        #       ${domain} @
        #     }
        #     dynamic_domains
        #     check_interval 5m
        #   }
        # '';
      };

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      networking.hosts = {
        "127.0.0.1" = [ "test.singerfamily.ca" ];
      };
    }
  );
}
