_:
let
  secretsPath = ../../../secrets;
in
{
  den.aspects.netbird.nixos =
    { config, ... }:
    {
      sops.secrets."keys/netbird" = {
        sopsFile = secretsPath + "/hosts/${config.networking.hostName}.yaml";
      };

      services.netbird.clients.wt0 = {
        login = {
          enable = true;
          setupKeyFile = config.sops.secrets."keys/netbird".path;
          systemdDependencies = [ "sops-install-secrets.service" ];
        };
        openFirewall = true;
      };
    };
}
