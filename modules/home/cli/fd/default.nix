# NOTE: `fd`, a simple, fast and user-friendly alternative to find (Home-manager module).

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.cli.fd.enable = mkOption {
    description = "Whether to enable fd - simple, fast and user-friendly alternative to find";
    type = with types; bool;
    default = true;
  };

  config =
    let
      inherit (config.snowfall.cli.fd)
        enable
        ;
    in
    mkIf enable {
      home = {
        packages = with pkgs; [ fd ];
        file.".fdignore".text = # git-ignore
          ''
            .git/
          '';
      };
    };
}
