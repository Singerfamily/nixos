_:
{
  den.aspects.fzf.homeManager =
    { pkgs, ... }:
    {
      programs.fzf = {
        enable = true;
        defaultOptions = [
          "--reverse"
          "--border=sharp"
          "--height=40%"
          "--bind=tab:down,btab:up,alt-j:down,alt-k:up"
          "--preview '([[ -f {} ]] && (${pkgs.bat}/bin/bat --style=numbers --color=always {} || cat {})) || echo {} 2> /dev/null | head -200'"
        ];
        fileWidgetCommand = "${pkgs.fd}/bin/fd --type f";
        fileWidgetOptions = [
          "--preview '${pkgs.bat}/bin/bat --style=numbers --color=always --line-range :500 {}'"
        ];
        historyWidgetOptions = [ "--exact" ];
        changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d";
      };
    };
}
