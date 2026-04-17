_:
{
  den.aspects.ollama.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        ollama-rocm
      ];
    };
}
