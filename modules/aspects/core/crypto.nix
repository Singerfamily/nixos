_:
{
  den.aspects.crypto.nixos =
    { pkgs, ... }:
    {
      programs.gnupg.agent.enable = true;
      environment.systemPackages = with pkgs; [
        sops
        ssh-to-age
        age
        rage
        cryptsetup
      ];
    };
}
