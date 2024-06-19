{pkgs, ...}: 

{
    imports = [
        ./docker.nix
        ./git.nix
        ./nvidia.nix
        ./locale.nix
        ./pipewire.nix
        ./tailscale.nix
        ./zsh.nix
        ./nix.nix
    ];

    environment.sessionVariables = {
	  NIXOS_OZONE_WL = "1";
    };

    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
        vscode
	    microsoft-edge
        kdeconnect
        niv
        lanzaboote-tool
    ];
}
