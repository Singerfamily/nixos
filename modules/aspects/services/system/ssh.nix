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

          hostKeys = [
            {
              path = config.sops.secrets."ssh/private_key".path;
              type = "ed25519";
            }
          ];
        };
        programs.mosh = {
          enable = true;
          withUtempter = true;
        };

        programs.ssh = {
          startAgent = true;
        };

        environment.systemPackages = [ pkgs.sshfs ];

        sops.secrets."ssh/private_key" = {
          neededForUsers = true;
          sopsFile = ../../../../secrets/hosts + "/${config.networking.hostName}.yaml";
        };
      };
    homeManager = _: {
      programs.ssh.enable = true;
      services.ssh-agent.enable = true;
    };
  };
}
