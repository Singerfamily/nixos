{ config, pkgs, ... }:

{
	# NVIDIA services
	services.xserver.videoDrivers = [ "nvidia" ];

	hardware = {
		opengl = {
			enable = true;
			driSupport = true;
			driSupport32Bit=true;
			extraPackages = with pkgs;[ vaapiVdpau nvidia-vaapi-driver intel-media-driver]; 
		};

		nvidia = {
			modesetting.enable = true;
			powerManagement.enable = true;
			powerManagement.finegrained = false;
			open = true;
			nvidiaSettings = true;
			package = config.boot.kernelPackages.nvidiaPackages.production;
			
			prime = {
					sync.enable = true;
					intelBusId = "PCI:0:2:0";
					nvidiaBusId = "PCI:1:0:0";
			};

		};
	};
}
