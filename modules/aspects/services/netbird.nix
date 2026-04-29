_: {
  den.aspects.netbird.nixos =
    { pkgs, ... }:
    {
      # Status: wt0 interface is active and UI is enabled. Automatic login via
      # setup key is pending until "keys/netbird" is provisioned in
      # secrets/hosts/<hostname>.yaml. To enable: provision the secret, then
      # uncomment the sops.secrets block and the login block below.
      # sops.secrets."keys/netbird" = {
      #   sopsFile = secretsPath + "/hosts/${config.networking.hostName}.yaml";
      # };

      services.netbird.enable = true;
      services.resolved.enable = true;
      networking.firewall.trustedInterfaces = [ "wt0" ];
      systemd.services.netbird = {
        path = with pkgs; [ shadow ];
      };

      # services.netbird = {
      #   enable = true;
      #   ui.enable = true;
      #   clients.wt0 = {
      #     ui.enable = true;
      #     port = 51820;
      #     # login = {
      #     #   enable = true;
      #     #   setupKeyFile = config.sops.secrets."keys/netbird".path;
      #     #   systemdDependencies = [ "sops-install-secrets.service" ];
      #     # };
      #     openFirewall = true;
      #     openInternalFirewall = true;
      #   };
      # };
    };
}
