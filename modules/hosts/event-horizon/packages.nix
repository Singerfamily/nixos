_:
{
  den.aspects.event-horizon.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        android-tools
        openbao
      ];
    };
}
