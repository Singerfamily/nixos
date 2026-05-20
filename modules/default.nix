{
  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };
}
