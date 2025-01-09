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

      hosts = {
        "10.0.0.1" = [
          "fw.singerfamily.ca"
          "fw.lan.singerfamily.ca"
        ];
      };
    };
  };
}
