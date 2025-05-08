# INFO: NixOS TPM module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.aeon.tpm = {
    # Whether to use TPM2 for secure boot.
    enable = mkOption {
      type = with types; bool;
      default = false;
    };
  };

  config =
    let
      inherit (config.aeon.tpm) enable;
    in
    mkMerge [
      # TPM2: common options.
      (mkIf enable {
        boot.initrd = {
          systemd = {
            enable = true; # For auto unlock
            tpm2.enable = true;
          };
          kernelModules = [ "tpm_crb" ];
          availableKernelModules = [ "tpm_crb" ];
        };

        security.tpm2 = {
          enable = true;
          tctiEnvironment.enable = true;
        };
      })
    ];
}
