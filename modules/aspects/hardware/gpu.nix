{ den, ... }:
{
  # GPU aspect - included by hosts that need graphics acceleration
  # Each host should specify which GPU packages they need via provides
  den.aspects.gpu = {
    nixos =
      { lib, pkgs, ... }:
      {
        hardware.graphics = {
          enable = lib.mkDefault true;
          enable32Bit = lib.mkDefault true;
        };
        environment.sessionVariables.ELECTRON_OZONE_PLATFORM_HINT = lib.mkDefault "auto";
        environment.systemPackages = [ pkgs.nvtopPackages.full ];
      };
  };

  # Intel GPU sub-aspect
  den.aspects.gpu-intel = {
    includes = [ den.aspects.gpu ];
    nixos =
      { pkgs, lib, ... }:
      {
        hardware.graphics.extraPackages = with pkgs; [
          intel-media-driver
          libvdpau-va-gl
        ];
      };
  };

  # AMD GPU sub-aspect (RADV is enabled by default)
  den.aspects.gpu-amd = {
    includes = [ den.aspects.gpu ];
  };

  # NVIDIA GPU sub-aspect
  den.aspects.gpu-nvidia = {
    includes = [ den.aspects.gpu ];
    nixos =
      { lib, config, ... }:
      {
        hardware.nvidia = {
          modesetting.enable = lib.mkDefault true;
          open = lib.mkDefault true;
          nvidiaSettings = lib.mkDefault true;
          package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.latest;
        };
        services.xserver.videoDrivers = [ "nvidia" ];
      };
  };
}
