{pkgs, ...}: 

{
    imports = [
        ./nix
        ./boot
        ./networking
        ./locale.nix
        ./pipewire.nix
        ./fonts.nix
    ];

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
