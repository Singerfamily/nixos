{ inputs, ... }:
{
  den.aspects.flatpak = {
    nixos =
      { ... }:
      {
        imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

        services.flatpak.enable = true;
        xdg.portal.enable = true;
      };
    homeManager =
      { ... }:
      {
        imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

        services.flatpak = {
          remotes = [
            {
              name = "flathub";
              location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
            }
          ];
          update.auto.enable = true;
          update.onActivation = false;
          uninstallUnmanaged = true;
        };
      };
  };

  flake-file.inputs.nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
}
