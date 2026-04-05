{ den, ... }:
{
  # Common CLI tools - included by default for all users
  den.default.homeManager =
    { pkgs, lib, ... }:
    {
      news.display = lib.mkDefault "silent";

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
          enableZshIntegration = lib.mkDefault true;
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
        zoxide = {
          enable = lib.mkDefault true;
          options = lib.mkDefault [ "--cmd cd" ];
        };
      };

      home.packages = with pkgs; [
        bandwhich
        doggo
        dua
        duf
        gping
        kondo
        killall
        netdiscover
        nmap
        rustscan
        sd
        srm
        unrar
        unzip
        wakeonlan
        zip

        # System information
        file
        pciutils
        usbutils
        smartmontools
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

      systemd.user.startServices = lib.mkDefault "sd-switch";

      xdg.userDirs = {
        enable = lib.mkDefault true;
        createDirectories = lib.mkDefault true;
        setSessionVariables = lib.mkDefault false;
        desktop = lib.mkDefault "$HOME/Desktop";
        documents = lib.mkDefault "$HOME/Documents";
        music = lib.mkDefault "$HOME/Music";
        pictures = lib.mkDefault "$HOME/Images";
        publicShare = lib.mkDefault null;
        templates = lib.mkDefault null;
        extraConfig.XDG_SCREENSHOTS_DIR = lib.mkDefault "$HOME/Images/Screenshots";
      };
      xdg.mime.enable = lib.mkDefault true;
      xdg.mimeApps.enable = lib.mkDefault true;
    };
}
