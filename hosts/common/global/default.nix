{pkgs, ...}: 

{
    imports = [
        ./docker.nix
        ./git.nix
        ./locale.nix
        ./nvidia.nix
        ./pipewire.nix
        ./tailscale.nix
        ./zsh.nix
        ./nix.nix
        ./browser.nix
    ];

    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
        vscode
	    microsoft-edge
        kdeconnect
    ];
}
