{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

with lib;
{
  options.snowfall.kernel = {
    type = mkOption {
      type = types.enum [
        "default"
        "zen"
        "cachy"
      ];
      default = "default";
      description = "What kind of Linux kernel to use";
    };
  };

  config = mkMerge [
    (mkIf (config.snowfall.kernel.type == "zen") {
      boot.kernelPackages = pkgs.linuxPackages_zen;
    })
    (mkIf (config.snowfall.kernel.type == "cachy") {      
      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

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

    })
  ];
}
