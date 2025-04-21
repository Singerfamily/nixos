{ config, pkgs, lib, ... }: 
let 
	cfg = config.drivers.nvidia; 
in {
	options.drivers.nvidia = {
		enable = lib.mkEnableOption "Enable NVIDIA Drivers";
		prime = {
			enable = lib.mkEnableOption "Enable NVIDIA PRIME support";
			intelBusID = lib.mkOption {
				type = lib.types.str;
				default = "PCI:0:2:0";
			};
			nvidiaBusID = lib.mkOption {
				type = lib.types.str;
				default = "PCI:1:0:0";
			};

			mode = lib.mkOption {
				type = lib.types.enum [ "offload" "sync" ];
				default = "offload";
				description = ''
					Select the PRIME mode to use. The "offload" mode allows
					for offloading rendering to the NVIDIA GPU, while the
					"sync" mode allows for synchronizing the display output
					between the Intel and NVIDIA GPUs.
					Note that the "offload" mode requires the NVIDIA GPU to
					be the primary GPU in the system, while the "sync" mode
					requires the Intel GPU to be the primary GPU.
				'';
			};
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
				powerManagement = {
					enable = false;
					finegrained = false;
				};
				# dynamicBoost.enable = lib.mkForce true;
				open = true;
				nvidiaSettings = true;
				package = config.boot.kernelPackages.nvidiaPackages.production;

				prime = lib.mkIf cfg.prime.enable {
					offload = lib.mkIf (cfg.prime.mode == "offload") {
						enable = true;
						enableOffloadCmd = true;
					};

					# sync = lib.mkIf (cfg.prime.mode == "sync") {
					# 	enable = true;
					# };

					intelBusId = "${cfg.prime.intelBusID}";
					nvidiaBusId = "${cfg.prime.nvidiaBusID}";
				};
			};
		};
	};
}
