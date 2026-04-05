{
  config,
  lib,
  pkgs,
  ...
}:
{
  config =
    lib.mkIf
      (
        config.snowfall.cli.shell.default == "zsh"
        && (builtins.elem config.snowfall.core.type [
          "desktop"
          "laptop"
        ])
      )
      {

        home.packages = with pkgs; [
          zsh-powerlevel10k
        ];

        programs.zsh = {
          enable = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;

          initExtra = ''
            # npm global packages
            export NPM_CONFIG_PREFIX="$HOME/.npm-global"
            export PATH="$HOME/.npm-global/bin:$PATH"
          '';

          plugins = [
            {
              name = "powerlevel10k";
              src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
              file = "powerlevel10k.zsh-theme";
            }
          ];

          oh-my-zsh = {
            enable = true;
            plugins = [
              "git"
              "kubectl"
            ];
          };
        };
      };
}
