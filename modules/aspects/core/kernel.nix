{ den, inputs, ... }:
{
  # Zen kernel aspect — use linuxPackages_zen
  den.aspects.kernel-zen.nixos =
    { pkgs, lib, ... }:
    {
      boot.kernelPackages =  pkgs.linuxPackages_zen;
    };

  # CachyOS kernel aspect — use CachyOS kernel with custom substituters
  den.aspects.kernel-cachy.nixos =
    { pkgs, lib, ... }:
    {

      nixpkgs.overlays = [
        inputs.nix-cachyos-kernel.overlays.default
      ];

      # Requires chaotic-nyx or cachyos-kernel flake input for pkgs.cachyosKernels
      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;
      nix.settings = {
        substituters = [
          "https://attic.xuyh0120.win/lantian"
          "https://cache.garnix.io"
        ];
        trusted-public-keys = [
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        ];
      };
    };

  flake-file.inputs = {
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
  };
}
