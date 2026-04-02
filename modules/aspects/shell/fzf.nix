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
      ];
      fileWidgetCommand = lib.mkDefault "${pkgs.fd}/bin/fd --type f";
      changeDirWidgetCommand = lib.mkDefault "${pkgs.fd}/bin/fd --type d";
    };
  };
}
