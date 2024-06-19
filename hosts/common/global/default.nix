{pkgs, ...}: 

{
    imports = [
        ./git.nix
        ./pipewire.nix
        ./tailscale.nix
        ./zsh.nix
        ./nvidia.nix
        # ./docker.nix
        # ./locale.nix
        # ./nix.nix
        # ./auto-upgrade.nix
        # ./dns.nix
        # ./mac-randomize.nix
    ];

    environment.sessionVariables = {
	  NIXOS_OZONE_WL = "1";
    };

    nixpkgs.config.allowUnfree = true;

    programs.firefox.enable = true;

    environment.systemPackages = with pkgs; [
        vscode
	    microsoft-edge-dev
        kdeconnect
        niv
        tpm2-tss
        aha
    ];
}
