_:
{
  den.aspects.ollama = {
    nixos =
      { pkgs, ... }:
      {
        services.ollama = {
          enable = true;
          package = pkgs.ollama-cuda;
        };
      };
  };
}
