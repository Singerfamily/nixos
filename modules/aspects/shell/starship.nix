{ den, ... }:
{
  den.aspects.starship.homeManager = { lib, ... }: {
    programs.starship = {
      enable = lib.mkDefault true;
      enableZshIntegration = lib.mkDefault true;
      enableBashIntegration = lib.mkDefault true;
      enableTransience = lib.mkDefault true;
      settings = {
        add_newline = lib.mkDefault false;
        format = lib.mkDefault "$all";
        right_format = lib.mkDefault "$kubernetes";
        directory.style = lib.mkDefault "bold lavender";
        aws.disabled = lib.mkDefault true;
        docker_context.symbol = lib.mkDefault " ";
        golang.symbol = lib.mkDefault " ";
        helm.symbol = lib.mkDefault " ";
        gradle.symbol = lib.mkDefault " ";
        java.symbol = lib.mkDefault " ";
        kotlin.symbol = lib.mkDefault " ";
        lua.symbol = lib.mkDefault " ";
        package.symbol = lib.mkDefault " ";
        php.symbol = lib.mkDefault " ";
        python.symbol = lib.mkDefault " ";
        rust.symbol = lib.mkDefault " ";
        terraform.symbol = lib.mkDefault " ";
        kubernetes = {
          disabled = lib.mkDefault false;
          style = lib.mkDefault "bold pink";
          symbol = lib.mkDefault "󱃾 ";
          format = lib.mkDefault "[$symbol$context( \\($namespace\\))]($style)";
          contexts = lib.mkDefault [
            {
              context_pattern = "arn:aws:eks:(?P<var_region>.*):(?P<var_account>[0-9]{12}):cluster/(?P<var_cluster>.*)";
              context_alias = "$var_cluster";
            }
          ];
        };
      };
    };
  };
}
