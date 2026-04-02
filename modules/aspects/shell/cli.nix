{ den, ... }:
{
  # Common CLI tools - included by default for all users
  den.default.homeManager =
    { pkgs, lib, ... }:
    {
      programs = {
        home-manager.enable = lib.mkDefault true;
        nix-index.enable = lib.mkDefault true;
        htop.enable = lib.mkDefault true;
        btop.enable = lib.mkDefault true;
        direnv = {
          enable = lib.mkDefault true;
          nix-direnv.enable = lib.mkDefault true;
        };
        eza = {
          enable = lib.mkDefault true;
          git = lib.mkDefault true;
          icons = lib.mkDefault "auto";
        };
        bat = {
          enable = lib.mkDefault true;
          config = {
            theme = lib.mkDefault "base16";
            style = lib.mkDefault "plain,grid,numbers,changes,snip";
          };
        };
        fd.enable = lib.mkDefault true;
        ripgrep.enable = lib.mkDefault true;
        zoxide.enable = lib.mkDefault true;
      };

      home.packages = with pkgs; [
        dua
        duf
        kondo
        killall
        sd
        srm
        unrar
        unzip
        zip
      ];

      home.shellAliases = {
        ls = "eza";
        ll = "eza -l";
        lla = "eza -la";
        tree = "eza --tree";
        cat = "bat";
      };

      xdg.userDirs = {
        enable = lib.mkDefault true;
        desktop = lib.mkDefault "$HOME/Desktop";
        documents = lib.mkDefault "$HOME/Documents";
        music = lib.mkDefault "$HOME/Music";
        pictures = lib.mkDefault "$HOME/Images";
      };
    };
}
