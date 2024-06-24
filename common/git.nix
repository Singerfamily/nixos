{config, lib, pkgs, ...}:

{

  programs.git = {
    enable = true;

		config = {
			init = {
				defaultBranch = "main";
			};
		};

    # userName = "LeaderbotX400";
    # userEmail = "eric@singerfamily.ca";
  };
}
