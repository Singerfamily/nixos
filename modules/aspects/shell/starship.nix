{ den, ... }:
{
  den.aspects.starship.homeManager = { lib, ... }: {
    programs.starship = {
      enable = lib.mkDefault true;
      settings = {
        format = lib.mkDefault "$all";
        right_format = lib.mkDefault "$kubernetes";
        docker_context.symbol = lib.mkDefault " ";
        golang.symbol = lib.mkDefault " ";
        helm.symbol = lib.mkDefault "⎈ ";
        java.symbol = lib.mkDefault " ";
        kotlin.symbol = lib.mkDefault " ";
        lua.symbol = lib.mkDefault " ";
        python.symbol = lib.mkDefault " ";
        rust.symbol = lib.mkDefault "🦀 ";
        terraform.symbol = lib.mkDefault "💠 ";
        kubernetes = {
          disabled = lib.mkDefault false;
          symbol = lib.mkDefault "⛵ ";
        };
      };
    };
  };
}
