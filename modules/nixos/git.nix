{config, lib, pkgs, ...}:

{
	programs.git = {
		enable = true;

		config = {
			userName = "LeaderbotX400";
			userEmail = "eric@singerfamily.ca";
			
		};
	};
}
