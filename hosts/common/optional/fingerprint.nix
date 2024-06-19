{config, pkgs, ...}:

{
  services.fprintd = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    fprintd
  ];

  security.pam.services.fprintd.fprintAuth = true;
}