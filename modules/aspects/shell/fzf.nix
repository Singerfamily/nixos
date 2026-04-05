{ den, ... }:
{
  den.aspects.fzf.homeManager = { lib, pkgs, ... }: {
    programs.fzf = {
      enable = lib.mkDefault true;
      defaultOptions = lib.mkDefault [
        "--reverse"
        "--border=sharp"
        "--height=40%"
        "--bind=tab:down,btab:up,alt-j:down,alt-k:up"
        "--preview '([[ -f {} ]] && (${pkgs.bat}/bin/bat --style=numbers --color=always {} || cat {})) || echo {} 2> /dev/null | head -200'"
      ];
      fileWidgetCommand = lib.mkDefault "${pkgs.fd}/bin/fd --type f";
      fileWidgetOptions = lib.mkDefault [
        "--preview '${pkgs.bat}/bin/bat --style=numbers --color=always --line-range :500 {}'"
      ];
      historyWidgetOptions = lib.mkDefault [ "--exact" ];
      changeDirWidgetCommand = lib.mkDefault "${pkgs.fd}/bin/fd --type d";
    };
  };
}
