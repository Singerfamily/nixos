{ config, pkgs, lib, ... }: 
let 
	cfg = config.nvidia; 
in {
	options = {
		nvidia = {
			enable = lib.mkEnableOption "Enable NVIDIA Drivers";
			prime = lib.mkEnableOption "Enable NVIDIA PRIME support";
		};
	};

	config = lib.mkIf cfg.enable {
		
		services.xserver.videoDrivers = [ "nvidia" ];

		hardware = {
			graphics = {
				enable = true;
				enable32Bit = true;
				extraPackages = with pkgs;[ vaapiVdpau nvidia-vaapi-driver intel-media-driver]; 
			};

			nvidia = {
				modesetting.enable = true;
				powerManagement.enable = true;
				powerManagement.finegrained = cfg.prime;
				open = false;
				nvidiaSettings = true;
				package = config.boot.kernelPackages.nvidiaPackages.production;
	
				prime = lib.mkIf config.nvidia.prime {
					offload = {
						enable = true;
						enableOffloadCmd = true;
					};

					intelBusId = "PCI:0:2:0";
					nvidiaBusId = "PCI:1:0:0";
				};
			};
		};
	};
}
