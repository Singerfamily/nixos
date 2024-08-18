{ pkgs, ... }: {
  imports = [
    ./secureboot.nix
  ];
  boot.initrd.systemd.enable = true;  # For auto unlock
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.plymouth.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.systemd.enableTpm2 = true;
  boot.initrd.kernelModules = [ "tpm_crb" ];
  boot.initrd.availableKernelModules = ["tpm_crb"];
  security.tpm2.enable = true;
  security.tpm2.tctiEnvironment.enable = true;
}
