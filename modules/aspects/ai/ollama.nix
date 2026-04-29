_: {
  den.aspects.ollama.nixos =
    { pkgs, ... }:
    {
      services.ollama = {
        package = pkgs.ollama-rocm;
        enable = true;
        # acceleration = "rocm";
        environmentVariables = {
          HSA_OVERRIDE_GFX_VERSION = "11.0.2";
        };
      };
      # services.open-webui = {
      #   enable = true;
      #   package = pkgs.open-webui;
      #   environment = {
      #     ANONYMIZED_TELEMETRY = "False";
      #     DO_NOT_TRACK = "True";
      #     SCARF_NO_ANALYTICS = "True";
      #     OLLAMA_API_BASE_URL = "http://127.0.0.1:11434/api";
      #     OLLAMA_BASE_URL = "http://127.0.0.1:11434";
      #   };
      # };
    };
}
