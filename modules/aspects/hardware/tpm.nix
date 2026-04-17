_:
{
  den.aspects.tpm.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.tpm2-tools ];
      boot.initrd = {
        systemd = {
          enable = true;
          tpm2.enable = true;
        };
        kernelModules = [ "tpm_crb" ];
        availableKernelModules = [ "tpm_crb" ];
      };
      security.tpm2 = {
        enable = true;
        tctiEnvironment.enable = true;
      };
    };
}
