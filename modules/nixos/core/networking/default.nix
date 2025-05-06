{
  hostname,
  isWSL,
  lib,
  ...
}:
{
  imports = [
    ./dns.nix
  ];

  config = lib.mkIf (!isWSL) {
    networking = {
      networkmanager.enable = true;

      hostName = "${hostname}";
    };
  };
}
