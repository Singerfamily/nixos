{pkgs, ...}: 

{
    imports = [
        ./docker.nix
        ./git.nix
        ./locale.nix
        ./nvidia.nix
        ./sound.nix
        ./tailscale.nix
        ./zsh.nix
    ];

    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
        vscode
	    microsoft-edge
        kdeconnect
    ];
}
