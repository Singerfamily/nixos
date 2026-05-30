{ den, ... }:
{
  den.aspects.ssh = {
    nixos =
      { pkgs, config, ... }:
      {
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = true;
            PermitRootLogin = "no";
            StreamLocalBindUnlink = "yes";
          };

          # hostKeys = [
          #   {
          #     path = config.sops.secrets."ssh/private_key".path;
          #     type = "ed25519";
          #   }
          # ];
        };
        programs.mosh = {
          enable = true;
          withUtempter = true;
        };

        programs.ssh = {
          startAgent = true;
        };

        environment.systemPackages = [ pkgs.sshfs ];

        # sops.secrets."ssh/private_key" = {
        #   neededForUsers = true;
        #   sopsFile = ../../../../secrets/hosts + "/${config.networking.hostName}.yaml";
        # };
      };
    homeManager =
      { pkgs, ... }:
      {
        programs.ssh.enable = true;
        services.ssh-agent.enable = true;

        programs.ssh.enableDefaultConfig = false;

        # Forgejo SSH over 443 (TLS-wrapped, routed by SNI)
        programs.ssh.settings = {
          "forgejo.singerfamily.ca git.s10y.ca s10y.ca" = {
            HostName = "fj-ssh.singerfamily.ca";
            Port = 443;
            User = "git";
            ProxyCommand = "${pkgs.openssl}/bin/openssl s_client -connect %h:%p -quiet 2>/dev/null";
            IdentityFile = "~/.ssh/id_ed25519";
          };
        };
      };
  };
}
