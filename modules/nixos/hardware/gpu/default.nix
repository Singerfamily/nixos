# {
#   config,
#   pkgs,
#   lib,
#   ...
# }:
# let
#   cfg = config.drivers.nvidia;
# in
# {
#   options.drivers.nvidia = {
#     prime = {
#       enable = lib.mkEnableOption "Enable NVIDIA PRIME support";
#       intelBusID = lib.mkOption {
#         type = lib.types.str;
#         default = "PCI:0:2:0";
#       };
#       nvidiaBusID = lib.mkOption {
#         type = lib.types.str;
#         default = "PCI:1:0:0";
#       };

#       mode = lib.mkOption {
#         type = lib.types.enum [
#           "offload"
#           "sync"
#         ];
#         default = "offload";
#         description = ''
#           					Select the PRIME mode to use. The "offload" mode allows
#           					for offloading rendering to the NVIDIA GPU, while the
#           					"sync" mode allows for synchronizing the display output
#           					between the Intel and NVIDIA GPUs.
#           					Note that the "offload" mode requires the NVIDIA GPU to
#           					be the primary GPU in the system, while the "sync" mode
#           					requires the Intel GPU to be the primary GPU.
#           				'';
#       };
#     };
#   };

#   config = {
#     nixpkgs.config.packageOverrides = pkgs: {
#       vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
#     };
#     services.xserver.videoDrivers = [ "nvidia" ];

#     hardware = {
#       graphics = {
#         enable = true;
#         enable32Bit = true;
#         extraPackages = with pkgs; [
#           vaapiVdpau
#           nvidia-vaapi-driver
#           intel-media-driver

#           vaapiIntel
#           vaapiVdpau
#           libvdpau-va-gl
#         ];
#       };

#       nvidia = {
#         modesetting.enable = true;
#         powerManagement = {
#           enable = false;
#           finegrained = false;
#         };
#         # dynamicBoost.enable = lib.mkForce true;
#         open = true;
#         nvidiaSettings = true;
#         package = config.boot.kernelPackages.nvidiaPackages.production;

#         prime = lib.mkIf cfg.prime.enable {
#           offload = lib.mkIf (cfg.prime.mode == "offload") {
#             enable = true;
#             enableOffloadCmd = true;
#           };

#           # sync = lib.mkIf (cfg.prime.mode == "sync") {
#           # 	enable = true;
#           # };

#           intelBusId = "${cfg.prime.intelBusID}";
#           nvidiaBusId = "${cfg.prime.nvidiaBusID}";
#         };
#       };
#     };
#   };
# }

# INFO: NixOS GPU module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.hardware.gpu = {
    core.enable = mkOption {
      description = "Whether to add common GPU-related modules";
      type = with types; bool;
      default = true;
    };

    intel = {
      enable = mkOption {
        description = "Whether to support Intel graphics";
        type = with types; bool;
        default = true;
      };
      busID = mkOption {
        description = "Intel iGPU PCI bus ID";
        type = with types; nullOr str;
        default = null;
      };
    };

    nvidia = {
      enable = mkOption {
        description = "Whether to support NVIDIA graphics";
        type = with types; bool;
        default = false;
      };
      busID = mkOption {
        description = "NVIDIA dGPU PCI bus ID";
        type = with types; nullOr str;
        default = null;
      };
    };

    specialise = mkOption {
      description = "Whether to split iGPU/dGPU specialisations";
      type = with types; bool;
      default = false;
    };
  };

  config =
    let
      # nvidiaPackage = config.hardware.nvidia.package;
      nvidiaConfig = {
        # boot.blacklistedKernelModules = [ "nouveau" ];
        services.xserver.videoDrivers = [ "nvidia" ];
        hardware.nvidia = {
          package = config.boot.kernelPackages.nvidiaPackages.stable;
          modesetting.enable = true;
          powerManagement = {
            enable = false;
            finegrained = false;
          };
          open = true;
          # open = lib.mkOverride 990 (nvidiaPackage ? open && nvidiaPackage ? firmware);
          prime = {
            intelBusId = intel.busID;
            nvidiaBusId = nvidia.busID;

            offload = {
              enable = true;
              enableOffloadCmd = true;
            };
          };
        };
      };
      inherit (config.snowfall.hardware.gpu)
        core
        intel
        nvidia
        specialise
        ;
    in
    mkMerge [
      (mkIf core.enable {
        # Exclude `nvtop` from minimal systems.
        environment.systemPackages =
          with pkgs;
          (
            if
              !(builtins.elem config.networking.hostName [
              ])
            then
              [ (nvtopPackages.intel.override { nvidia = true; }) ]
            else
              [
                nvtopPackages.full
              ]
          );
      })

      (mkIf intel.enable {
        nixpkgs.config.packageOverrides = pkgs: {
          vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
        };
        services.xserver.videoDrivers = [
          "modesetting"
          "intel"
        ];
        hardware = {
          graphics = {
            enable = true;
            enable32Bit = true;
            extraPackages = with pkgs; [
              intel-media-driver
              vaapiIntel
              vaapiVdpau
              libvdpau-va-gl
            ];
          };
        };
      })

      (mkIf (nvidia.enable && !specialise) nvidiaConfig)

      (mkIf (nvidia.enable && specialise) (mkMerge [
        # Create a dGPU spec with the necessary drivers.
        {
          specialisation."dGPU".configuration = mkMerge [
            {
              system.nixos.label = "${config.networking.hostName}-dGPU";
            }
            nvidiaConfig
          ];
        }

        # Disable the NVIDIA dGPU in the default specialisation.
        #
        # NOTE: Stolen from https://github.com/NixOS/nixos-hardware/blob/master/common/gpu/nvidia/disable.nix
        (mkIf (config.specialisation != { }) {
          boot = {
            blacklistedKernelModules = [
              "nouveau"
              "nvidia"
              "nvidia_drm"
              "nvidia_modeset"
            ];

            extraModprobeConfig = ''
              blacklist nouveau
              options nouveau modeset=0
            '';
          };

          system.nixos.label = "${config.networking.hostName}-iGPU";
          services.udev.extraRules = # python
            ''
              # Remove NVIDIA USB xHCI Host Controller devices, if present.
              ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
              # Remove NVIDIA USB Type-C UCSI devices, if present.
              ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
              # Remove NVIDIA Audio devices, if present.
              ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
              # Remove NVIDIA VGA/3D controller devices.
              ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
            '';
        })
      ]))
    ];
}
