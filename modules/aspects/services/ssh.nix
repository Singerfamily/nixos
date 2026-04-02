{ den, ... }:
{
  den.aspects.ssh = {
    nixos =
      { lib, pkgs, ... }:
      {
        services.openssh = {
          enable = lib.mkDefault true;
          settings = {
            PasswordAuthentication = lib.mkDefault false;
            PermitRootLogin = lib.mkDefault "no";
          };
        };
        programs.mosh.enable = lib.mkDefault true;
        environment.systemPackages = [ pkgs.sshfs ];
      };
    homeManager = { lib, ... }: {
      services.ssh-agent.enable = lib.mkDefault true;
    };
  };
}
