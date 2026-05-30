{ inputs, ... }:
{
  # Zen kernel aspect — use linuxPackages_zen
  den.aspects.kernel-zen.nixos =
    { pkgs, ... }:
    {
      boot.kernelPackages = pkgs.linuxPackages_zen;
    };

  # CachyOS kernel aspect — use CachyOS kernel with custom substituters
  den.aspects.kernel-cachy.nixos =
    { pkgs, ... }:
    {

      nixpkgs.overlays = [
        inputs.nix-cachyos-kernel.overlays.default
      ];

      # Alternative: pre-built binary (no custom options or module overrides).
      # Current build uses the override below for full kernel config control.
      # boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;

      boot.kernelPackages =
        let
          # helpers.nix provides a few utilities for building kernel with LTO.
          # I haven't figured out a clean way to expose it in flakes.
          helpers = pkgs.callPackage "${inputs.nix-cachyos-kernel.outPath}/helpers.nix" { };

          kernel = inputs.nix-cachyos-kernel.packages.x86_64-linux.linux-cachyos-latest.override {
            cpusched = "bore";
            lto = "full";
            processorOpt = "zen4";
            hzTicks = "1000";
            bbr3 = true;
            autofdo = true;
          };
        in
        helpers.kernelModuleLLVMOverride (pkgs.linuxKernel.packagesFor kernel);

      nix.settings = {
        substituters = [
          "https://attic.xuyh0120.win/lantian"
        ];
        trusted-public-keys = [
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        ];
      };
    };

  flake-file.inputs = {
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
  };
}
