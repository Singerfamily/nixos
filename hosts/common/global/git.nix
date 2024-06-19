{config, lib, pkgs, ...}:

{
	programs.git = {
		enable = true;

		confit = {
			initBranch = "main";
		};

		# userName = "LeaderbotX400";
		# userEmail = "eric@singerfamily.ca";
	};
}
