{ den, ... }:
{
  den.hosts.x86_64-linux.clint-pc.users.csinger = { };

  den.aspects.clint-pc = {
    includes = with den.aspects; [
      profile-desktop
      profile-managed
      gpu-nvidia-prime
      qemu
      sunshine
      ollama
    ];

    nixos =
      _:
      {
        den.gpuPrime = {
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };
  };
}
