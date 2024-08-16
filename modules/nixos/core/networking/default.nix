{ hostname, ...}: {
  imports = [
    ./dns.nix
  ];

  networking = {
    networkmanager.enable = true;

    hostName = "${hostname}";

    hosts = {
      "10.0.0.1" = ["fw.singerfamily.ca"  "fw.lan.singerfamily.ca"];
    };
  };
}