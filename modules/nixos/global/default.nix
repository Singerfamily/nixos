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
    ];

    networking.networkmanager.enable = true;

    nixpkgs.config.allowUnfree = true;
    hardware.enableAllFirmware = true;

    programs.git.enable = true;
    programs.zsh.enable = true;

    environment.systemPackages = with pkgs; [
        gh
        niv
        krdc
	    vscode
        tpm2-tss
        binutils
        librewolf
        kdeconnect
	    microsoft-edge-dev
        fira-code-nerdfont
    ];
}
