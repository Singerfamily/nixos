{ den, ... }:
{
  den.aspects.network = {
    nixos = { lib, pkgs, ... }: {
      networking = {
        networkmanager.enable = lib.mkDefault true;
        firewall.enable = lib.mkDefault true;
        useDHCP = lib.mkDefault true;
      };
      environment.systemPackages = with pkgs; [
        dig
        ethtool
        iperf3
      ];
    };
  };
}
