{config, pkgs, lib, ...}: {
  imports = [
    home-manager.nixosModules.home-manager

    ./shell/zsh.nix
  ];
  
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}