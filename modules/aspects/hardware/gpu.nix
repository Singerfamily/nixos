{ den, ... }:
{
  # GPU aspect - included by hosts that need graphics acceleration
  # Each host should specify which GPU packages they need via provides
  den.aspects.gpu = {
    nixos =
      { lib, pkgs, ... }:
      {
        hardware.graphics = {
          enable =  true;
          enable32Bit =  true;
        };
        environment.sessionVariables.ELECTRON_OZONE_PLATFORM_HINT =  "auto";
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
        services.xserver.videoDrivers =  [ "intel" ];
      };
  };

  # AMD GPU sub-aspect
  den.aspects.gpu-amd = {
    includes = [ den.aspects.gpu ];
    nixos = { lib, ... }: {
      hardware.amdgpu.initrd.enable =  true;
      hardware.amdgpu.opencl.enable =  true;
      services.xserver.videoDrivers =  [ "amdgpu" ];
    };
  };

  # NVIDIA GPU sub-aspect
  den.aspects.gpu-nvidia = {
    includes = [ den.aspects.gpu ];
    nixos =
      { lib, config, ... }:
      {
        hardware.nvidia = {
          modesetting.enable =  true;
          open =  true;
          nvidiaSettings =  true;
          gsp.enable =  true;
          package =  config.boot.kernelPackages.nvidiaPackages.latest;
          powerManagement.enable =  false;
          powerManagement.finegrained =  false;
          # PRIME mode configured per-host (offload vs sync)
          # prime.offload.enable =  true;
          # prime.offload.enableOffloadCmd =  true;
        };
        services.xserver.videoDrivers = [ "nvidia" ];
        boot.blacklistedKernelModules = [ "nouveau" ];

        environment.sessionVariables = {
          GBM_BACKEND =  "nvidia-drm";
          __GLX_VENDOR_LIBRARY_NAME =  "nvidia";
          NVD_BACKEND =  "direct";
        };

        # Enable NVIDIA container toolkit for Docker GPU access
        hardware.nvidia-container-toolkit = {
          enable = true;
          mount-nvidia-executables = true;
        };
      };
  };
}
