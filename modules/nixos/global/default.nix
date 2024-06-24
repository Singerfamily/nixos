{pkgs, ...}: 

{
    imports = [
        # System Config
        ./nix
        ./boot.nix

        ./auto-upgrade.nix
        ./cachix.nix
        ./dns.nix
        ./locale.nix
        ./mac-randomize.nix
        ./pipewire.nix
        ./podman.nix
    ];

    environment.sessionVariables = {
	  NIXOS_OZONE_WL = "1";
    };

    nixpkgs.config.allowUnfree = true;

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
