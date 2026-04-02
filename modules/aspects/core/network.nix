{ den, ... }:
{
  den.default.nixos = { lib, pkgs, ... }: {
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
}
