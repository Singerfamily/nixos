_:
let
  secretsPath = ../../../secrets;
in
{
  den.aspects.netbird.nixos =
    { config, pkgs, ... }:
    {
      # sops.secrets."keys/netbird" = {
      #   sopsFile = secretsPath + "/hosts/${config.networking.hostName}.yaml";
      # };

      services.netbird = {
        enable = true;
        ui.enable = true;
        clients.wt0 = {
          ui.enable = true;
          port = 51820;
          # login = {
          #   enable = true;
          #   setupKeyFile = config.sops.secrets."keys/netbird".path;
          #   systemdDependencies = [ "sops-install-secrets.service" ];
          # };
          openFirewall = true;
          openInternalFirewall = true;
        };
      };
    };
}
