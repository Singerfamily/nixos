{ den, ... }:
{
  den.default.nixos = { pkgs, lib, ... }: {
    fonts.packages = lib.mkDefault (with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg
    ]);
  };
}
