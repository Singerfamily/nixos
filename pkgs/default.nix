{pkgs, ...}: 

{
    imports = [
        ./zsh.nix
    ];

    nixpkgs.config.allowUnfree = true;

    virtualisation.docker.enable = true;

    programs.firefox.enable = true;

    environment.systemPackages = with pkgs; [
        vscode
        tailscale
    ];
}