{ den, ... }:
{
  # LXC/LXD/Incus container support.
  # Disabled by default — add to host includes to enable.
  # For Incus, nftables is required and iptables firewall won't work.
  den.aspects.lxc.nixos =
    { lib, ... }:
    {
      virtualisation.lxc.enable =  true;

      boot.kernelModules = [
        "br_netfilter"
        "veth"
      ];
      boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = true;
        "net.ipv6.conf.all.forwarding" = true;
      };
      boot.supportedFilesystems = [ "zfs" ];
    };

  den.aspects.lxd = {
    includes = [ den.aspects.lxc ];
    nixos = { lib, ... }: {
      virtualisation.lxd = {
        enable =  true;
        recommendedSysctlSettings =  true;
      };
    };
  };

  den.aspects.incus = {
    includes = [ den.aspects.lxc ];
    nixos = { lib, ... }: {
      virtualisation.incus.enable =  true;
      networking = {
        nftables.enable =  true;
        firewall.trustedInterfaces = [ "incusbr0" ];
      };
    };
  };
}
