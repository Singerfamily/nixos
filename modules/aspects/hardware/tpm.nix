{ den, ... }:
{
  den.aspects.tpm.nixos = { pkgs, lib, ... }: {
    environment.systemPackages = [ pkgs.tpm2-tools ];
    boot.initrd = {
      systemd = {
        enable = lib.mkDefault true;
        tpm2.enable = lib.mkDefault true;
      };
      kernelModules = [ "tpm_crb" ];
      availableKernelModules = [ "tpm_crb" ];
    };
    security.tpm2 = {
      enable = lib.mkDefault true;
      tctiEnvironment.enable = lib.mkDefault true;
    };
  };
}
