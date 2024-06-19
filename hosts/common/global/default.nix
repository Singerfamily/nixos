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
    ];

    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
        vscode
	    microsoft-edge
        kdeconnect
    ];
}
