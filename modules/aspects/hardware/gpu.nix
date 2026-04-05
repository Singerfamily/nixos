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
          intel-vaapi-driver
          libvdpau-va-gl
        ];
        services.xserver.videoDrivers = lib.mkDefault [ "intel" ];
      };
  };

  # AMD GPU sub-aspect
  den.aspects.gpu-amd = {
    includes = [ den.aspects.gpu ];
    nixos = { lib, ... }: {
      hardware.amdgpu.initrd.enable = lib.mkDefault true;
      hardware.amdgpu.opencl.enable = lib.mkDefault true;
      services.xserver.videoDrivers = lib.mkDefault [ "amdgpu" ];
    };
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
          gsp.enable = lib.mkDefault true;
          package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.latest;
          powerManagement.enable = lib.mkDefault false;
          powerManagement.finegrained = lib.mkDefault false;
          prime.offload.enable = lib.mkDefault true;
          prime.offload.enableOffloadCmd = lib.mkDefault true;
        };
        services.xserver.videoDrivers = [ "nvidia" ];
        boot.blacklistedKernelModules = [ "nouveau" ];

        environment.sessionVariables = {
          GBM_BACKEND = lib.mkDefault "nvidia-drm";
          __GLX_VENDOR_LIBRARY_NAME = lib.mkDefault "nvidia";
          NVD_BACKEND = lib.mkDefault "direct";
        };

        # Enable NVIDIA container toolkit for Docker GPU access
        hardware.nvidia-container-toolkit = {
          enable = true;
          mount-nvidia-executables = true;
        };
      };
  };
}
