{ den, ... }:
{
  den.aspects.dnscrypt.nixos = { lib, ... }: {
    services.dnscrypt-proxy2 = {
      enable = lib.mkDefault true;
      upstreamDefaults = lib.mkDefault true;
      settings = {
        ipv4_servers = true;
        ipv6_servers = true;
        dnscrypt_servers = true;
        doh_servers = true;
        require_dnssec = true;
        require_nolog = true;
        require_nofilter = true;
        block_ipv6 = false;
        timeout = 5000;
        keepalive = 30;
        lb_strategy = "p2";
        lb_estimator = true;
        cache = true;
        force_tcp = false;
        bootstrap_resolvers = [ "1.1.1.1:53" "1.0.0.1:53" ];
        netprobe_address = "1.1.1.1:53";
        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        };
        server_names = [
          "cloudflare" "cloudflare-ipv6"
          "cloudflare-security" "cloudflare-security-ipv6"
          "adguard-dns-doh"
          "mullvad-adblock-doh" "mullvad-doh"
          "nextdns" "nextdns-ipv6"
          "quad9-dnscrypt-ipv4-filter-pri"
          "google" "google-ipv6"
        ];
      };
    };
  };
}
