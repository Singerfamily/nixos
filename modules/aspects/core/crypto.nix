{ den, ... }:
{
  den.aspects.crypto.nixos = { pkgs, lib, ... }: {
    programs.gnupg.agent.enable = lib.mkDefault true;
    environment.systemPackages = with pkgs; [
      sops
      ssh-to-age
      age
      rage
      cryptsetup
    ];
  };
}
