{pkgs, ...}: 

{
    imports = [
        # System Config
        ./locale.nix
        ./nix.nix
        ./auto-upgrade.nix
        ./dns.nix
        ./pipewire.nix
        ./tailscale.nix
        # ./docker.nix
        ./podman.nix
        ../desktop/plasma
        
        # User Config
        ./git.nix
        ./zsh.nix
        ./nvidia.nix
    ];

    environment.sessionVariables = {
	  NIXOS_OZONE_WL = "1";
    };

    nixpkgs.config.allowUnfree = true;

    programs.firefox.enable = true;

    environment.systemPackages = with pkgs; [
        fira-code-nerdfont
	    vscode
	    microsoft-edge-dev
        kdeconnect
        niv
        tpm2-tss
        aha
    ];
}
