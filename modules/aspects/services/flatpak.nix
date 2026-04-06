{ den, inputs, ... }:
{
  # Import nix-flatpak HM module globally so services.flatpak is always available
  den.default.homeManager.imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

  den.aspects.flatpak = {
    nixos =
      { lib, ... }:
      {
        imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];
        services.flatpak.enable =  true;
        xdg.portal.enable =  true;
        # Spotify Local Discovery + Google Cast
        networking.firewall.allowedTCPPorts =  [ 57621 ];
        networking.firewall.allowedUDPPorts =  [ 5353 ];
      };
    homeManager = { ... }: {
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
}
