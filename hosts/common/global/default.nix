{pkgs, ...}: 

{
    imports = [
        ./zsh.nix
        ./users.nix
        ./sound.nix
	    ./git.nix
    ];

    nixpkgs.config.allowUnfree = true;

    virtualisation.docker.enable = true;

    programs.firefox.enable = true;

    environment.systemPackages = with pkgs; [
        vscode
        tailscale
	    vscode
	    microsoft-edge
    ];
}
