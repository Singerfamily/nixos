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
        ./auto-upgrade.nix
        ./dns.nix
        # ./mac-randomize.nix
    ];

    environment.sessionVariables = {
	  NIXOS_OZONE_WL = "1";
    };

    nixpkgs.config.allowUnfree = true;

    packages.firefox.enable = true;

    environment.systemPackages = with pkgs; [
        vscode
	    microsoft-edge-dev
        kdeconnect
        niv
        tpm2-tss
        aha
    ];
}
