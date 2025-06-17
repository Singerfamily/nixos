{
  lib,
  config,
  ...
}:
with lib;
{
  options.snowfall.flatpak = {
    enable = mkOption {
      type = with types; bool;
      default = false;
      description = "Whether to enable Flatpak support";
    };

    packages = mkOption {
      type = with types; listOf strings;
      default = [ ];
      description = "List of Flatpak packages to install";
    };
  };

  config = mkIf config.snowfall.flatpak.enable {
    services.flatpak = {
      enable = true;
      remotes = [
        {
          name = "flathub";
          location = "https://flathub.org/repo/flathub.flatpakrepo";
        }
      ];
      update.auto.enable = false;
      uninstallUnmanaged = true;
      packages = config.snowfall.flatpak.packages;
    };
  };
}
