{ pkgs, ... }:

{
  # Enable printing
  services = {
    printing.enable = true;
    avahi.enable = true;
    avahi.nssmdns4 = true;
    avahi.openFirewall = true;
  };
  environment.systemPackages = [ pkgs.cups-filters ];
}