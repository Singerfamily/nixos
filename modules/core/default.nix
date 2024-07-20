{pkgs, ...}: 

{
    imports = [
        ./nix
        ./boot
        ./networking
        ./env-vars.nix
        ./locale.nix
        ./pipewire.nix
        ./fonts.nix
    ];

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
