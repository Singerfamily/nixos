_: {
  den.aspects.ollama.nixos =
    { pkgs, ... }:
    {
      services.ollama = {
        package = pkgs.ollama-rocm;
        enable = true;
        environmentVariables = {
          HSA_OVERRIDE_GFX_VERSION = "11.0.2";
        };
      };
    };
}
