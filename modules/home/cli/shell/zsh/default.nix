{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (config.snowfall.cli.shell.default == "zsh") {

    home.packages = with pkgs; [
      zsh-powerlevel10k
    ];

    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

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
