{pkgs, ...}: 

{
    imports = [
        ./nix
        ./boot.nix
        ./env-vars.nix
        ./auto-upgrade.nix
        ./dns.nix
        ./locale.nix
        # ./mac-randomize.nix
        ./pipewire.nix
        ./podman.nix

        ./24.05-compat.nix
    ];

    nixpkgs.config.allowUnfree = true;

    programs.git.enable = true;
    programs.zsh.enable = true;

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
