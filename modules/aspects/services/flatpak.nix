{ den, inputs, ... }:
{
  # Import nix-flatpak HM module globally so services.flatpak is always available
  den.default.homeManager.imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

  den.aspects.flatpak = {
    nixos =
      { lib, ... }:
      {
        imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];
        services.flatpak.enable = lib.mkDefault true;
        xdg.portal.enable = lib.mkDefault true;
        # Spotify Local Discovery + Google Cast
        networking.firewall.allowedTCPPorts = lib.mkDefault [ 57621 ];
        networking.firewall.allowedUDPPorts = lib.mkDefault [ 5353 ];
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
