{ den, ... }:
{
  den.aspects.ssh = {
    nixos =
      { lib, pkgs, ... }:
      {
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
            PermitRootLogin = "no";
            StreamLocalBindUnlink = "yes";
          };
        };
        programs.mosh = {
          enable = true;
          withUtempter = true;
        };

        programs.ssh = {
          startAgent = true;
        };

        environment.systemPackages = [ pkgs.sshfs ];
      };
    homeManager =
      { lib, ... }:
      {
        programs.ssh.enable = true;
        services.ssh-agent.enable = true;
      };
  };
}
