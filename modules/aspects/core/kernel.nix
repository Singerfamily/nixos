{ den, ... }:
{
  # Zen kernel aspect — use linuxPackages_zen
  den.aspects.kernel-zen.nixos =
    { pkgs, lib, ... }:
    {
      boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;
    };

  # CachyOS kernel aspect — use CachyOS kernel with custom substituters
  den.aspects.kernel-cachy.nixos =
    { lib, ... }:
    {
      # Requires chaotic-nyx or cachyos-kernel flake input for pkgs.cachyosKernels
      # boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
      nix.settings = {
        substituters = lib.mkDefault [
          "https://attic.xuyh0120.win/lantian"
          "https://cache.garnix.io"
        ];
        trusted-public-keys = lib.mkDefault [
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        ];
      };
    };
}
