_:
{
  den.aspects.ssh = {
    nixos =
      { pkgs, ... }:
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
      _:
      {
        programs.ssh.enable = true;
        services.ssh-agent.enable = true;
      };
  };
}
