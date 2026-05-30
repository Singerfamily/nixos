_: {
  # Default daily-driver CLI tooling — applied to every user via den.default.homeManager.
  den.default.homeManager =
    { pkgs, lib, ... }:
    {
      news.display = "silent";

      programs = {
        home-manager.enable = true;
        nix-index.enable = true;
        htop.enable = true;
        btop.enable = true;
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
        eza = {
          enable = true;
          git = true;
          icons = "auto";
          enableZshIntegration = true;
        };
        bat = {
          enable = true;
          config = {
            theme = "base16";
            style = "plain,grid,numbers,changes,snip";
          };
        };
        fd.enable = true;
        ripgrep.enable = true;
        zoxide = {
          enable = true;
          options = [ "--cmd cd" ];
        };
      };

      home.packages = with pkgs; [
        dua
        duf
        sd
        killall
        srm
        unrar
        unzip
        zip
      ];

      home.file.".fdignore".text = ".git/";

      home.shellAliases = {
        ls = "eza --group-directories-first --color=auto";
        ll = "eza -l";
        lla = "eza -la";
        tree = "eza --tree --level=3";
        cat = "bat";
        grep = "rg";
        df = "duf";
        du = "dua";
      };

      systemd.user.startServices = "sd-switch";

      xdg.userDirs = {
        enable = true;
        createDirectories = true;
        setSessionVariables = false;
        desktop = "$HOME/Desktop";
        documents = "$HOME/Documents";
        music = "$HOME/Music";
        pictures = "$HOME/Images";
        publicShare = null;
        templates = null;
        extraConfig.XDG_SCREENSHOTS_DIR = "$HOME/Images/Screenshots";
      };
      xdg.mime.enable = true;
    };
}
