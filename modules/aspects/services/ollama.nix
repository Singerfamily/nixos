_: {
  den.aspects.ollama = {
    nixos =
      { pkgs, ... }:
      {
        services.ollama = {
          enable = true;
          # CUDA build — this aspect is only attached to NVIDIA hosts
          # (clint-pc). `services.ollama.acceleration` was removed in 26.05.
          package = pkgs.ollama-cuda;
        };
      };
  };
}
