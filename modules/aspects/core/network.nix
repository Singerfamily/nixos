{ den, ... }:
{
  den.default.nixos =
    { lib, pkgs, ... }:
    {
      networking = {
        networkmanager.enable =  true;
        firewall.enable =  true;
        # useDHCP =  true;
      };
      environment.systemPackages = with pkgs; [
        dig
        ethtool
        iperf3
      ];
    };
}
