_:
{
  den.aspects.clint-pc.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        lsof
        nodejs
      ];
    };
}
