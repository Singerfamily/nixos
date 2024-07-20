{ config, pkgs, lib, ... }: 
with lib; let 
	cfg = config.drivers.nvidia; 
in {
	options.drivers.nvidia = {
		enable = mkEnableOption "Enable NVIDIA Drivers";
		prime = {
			enable = mkEnableOption "Enable NVIDIA PRIME support";
			intelBusID = mkOption {
				type = types.str;
				default = "PCI:1:0:0";
			};
			nvidiaBusID = mkOption {
				type = types.str;
				default = "PCI:0:2:0";
			};
		};
	};

	config = mkIf cfg.enable {
		
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
				powerManagement.finegrained = cfg.prime.enable;
				open = false;
				nvidiaSettings = true;
				package = config.boot.kernelPackages.nvidiaPackages.production;

				prime = mkIf cfg.prime.enable {
					offload = {
						enable = true;
						enableOffloadCmd = true;
					};

					intelBusId = "${cfg.prime.intelBusId}";
					nvidiaBusId = "${cfg.prime.nvidiaBusId}";
				};
			};
		};
	};
}
