{pkgs, ...}: 

{
    imports = [
        ./nix
        ./boot.nix
        ./env-vars.nix
        ./auto-upgrade.nix
        ./dns.nix
        ./network.nix
        ./locale.nix
        # ./mac-randomize.nix
        ./pipewire.nix
        ./podman.nix
        ./fonts.nix
    ];

    networking.networkmanager.enable = true;

    nixpkgs.config.allowUnfree = true;
    hardware.enableAllFirmware = true;

    programs = {
        git.enable = true;
        zsh.enable = true;
        direnv.enable = true;
        kdeconnect = {
            enable = true;
            # package = pkgs.kdePackages.kdeconnect-kde;
        };
    };

    environment.systemPackages = with pkgs; [
        gh
        niv
        krdc
	    vscode
        tpm2-tss
        binutils
        librewolf
	    microsoft-edge-dev
    ];
}
