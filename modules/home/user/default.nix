# INFO: This mostly will be used to expose config options that can be propagated to the systems
{lib, ...}: with lib; {
  options.snowfall.users = {
    fullName = mkOption {
      type = types.str;
      description = "Full name of the user.";
      default = "";
    };
  };
}