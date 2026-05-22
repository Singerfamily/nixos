{ den, ... }:
{
  # GPU aspect - included by hosts that need graphics acceleration
  # Each host should specify which GPU packages they need via provides
  den.aspects.gpu = {
    nixos = _: {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
      environment.sessionVariables.ELECTRON_OZONE_PLATFORM_HINT = "auto";
      # nvtop is installed per-GPU-vendor by the sub-aspects below.
    };
  };

  # Intel GPU sub-aspect. No nvtop here: in this fleet Intel is always the
  # iGPU half of a PRIME pair, and the discrete sub-aspect ships nvtop.
  den.aspects.gpu-intel = {
    includes = [ den.aspects.gpu ];
    nixos =
      { pkgs, ... }:
      {
        hardware.graphics.extraPackages = with pkgs; [
          intel-media-driver
          intel-vaapi-driver
          libvdpau-va-gl
        ];
        services.xserver.videoDrivers = [ "intel" ];
      };
  };

  # AMD GPU sub-aspect
  den.aspects.gpu-amd = {
    includes = [ den.aspects.gpu ];
    nixos =
      { pkgs, ... }:
      {
        hardware.amdgpu = {
          initrd.enable = true;
          opencl.enable = true;
        };

        boot.initrd.kernelModules = [ "amdgpu" ];
        boot.kernelModules = [ "amdgpu" ];
        services.xserver.videoDrivers = [ "amdgpu" ];
        boot.blacklistedKernelModules = [ "radeon" ];

        environment.systemPackages = [ pkgs.nvtopPackages.amd ];
      };
  };

  # NVIDIA GPU sub-aspect
  den.aspects.gpu-nvidia = {
    includes = [ den.aspects.gpu ];
    nixos =
      { config, pkgs, ... }:
      {
        hardware.nvidia = {
          modesetting.enable = true;
          open = true;
          nvidiaSettings = true;
          gsp.enable = true;
          package = config.boot.kernelPackages.nvidiaPackages.latest;
          powerManagement.enable = false;
          powerManagement.finegrained = false;
          # PRIME bus IDs are configured per-host by gpu-nvidia-prime.
        };
        services.xserver.videoDrivers = [ "nvidia" ];
        boot.blacklistedKernelModules = [ "nouveau" ];

        environment.systemPackages = [ pkgs.nvtopPackages.nvidia ];

        environment.sessionVariables = {
          GBM_BACKEND = "nvidia-drm";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          NVD_BACKEND = "direct";
        };

        # Enable NVIDIA container toolkit for Docker GPU access
        hardware.nvidia-container-toolkit = {
          enable = true;
          mount-nvidia-executables = true;
        };
      };
  };

  # NVIDIA PRIME hybrid aspect (Intel iGPU + NVIDIA dGPU offload)
  den.aspects.gpu-nvidia-prime = {
    includes = [
      den.aspects.gpu-nvidia
      den.aspects.gpu-intel
    ];
    nixos =
      { lib, config, ... }:
      {
        options.den.gpuPrime = {
          intelBusId = lib.mkOption {
            type = lib.types.str;
            description = "Intel iGPU PCI bus ID, e.g. PCI:0:2:0";
          };
          nvidiaBusId = lib.mkOption {
            type = lib.types.str;
            description = "NVIDIA dGPU PCI bus ID, e.g. PCI:1:0:0";
          };
        };
        config = {
          hardware.nvidia.prime = {
            offload.enable = true;
            offload.enableOffloadCmd = true;
            intelBusId = config.den.gpuPrime.intelBusId;
            nvidiaBusId = config.den.gpuPrime.nvidiaBusId;
          };
        };
      };
  };
}
