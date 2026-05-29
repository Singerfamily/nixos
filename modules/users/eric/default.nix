{
  den,
  inputs,
  lib,
  ...
}:
{
  den.homes.x86_64-linux.eric = { };

  den.aspects.eric = {
    includes = lib.mkMerge [
      (with den.aspects; [
        devenv
      ])
      (with den.batteries; [
        primary-user
        (user-shell "zsh")
      ])
    ];

    user = {
      name = "eric";
      description = "Eric Singer";
    };

    nixos =
      { pkgs, ... }:
      {
        fonts.packages = with pkgs; [
          nerd-fonts.jetbrains-mono
        ];

        fonts.fontconfig.defaultFonts = {
          serif = [ "JetBrainsMono Nerd Font" ];
          sansSerif = [ "JetBrainsMono Nerd Font" ];
          monospace = [ "JetBrainsMono Nerd Font Mono" ];
        };
      };

    homeManager =
      { pkgs, ... }:
      {
        imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

        news.display = "silent";

        programs = {
          home-manager.enable = true;
          nix-index.enable = true;

          btop.enable = true;

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
          microsoft-edge

          # Utils
          dua
          duf
          sd
          killall
          unrar
          unzip
          zip

          # Development
          distrobox
          distrobox-tui

          difftastic
          git-filter-repo
          forgejo-cli
          forgejo-mcp

          # Networking
          doggo

          # System
          pciutils
          usbutils
          smartmontools
        ];

        programs.zsh = {
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
          oh-my-zsh = {
            enable = true;
            plugins = [
              "git"
              "kubectl"
            ];
          };
          plugins = [
            {
              name = "powerlevel10k";
              src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
              file = "powerlevel10k.zsh-theme";
            }
            {
              name = "powerlevel10k-config";
              src = ./dotfiles;
              file = "p10k.zsh";
            }
          ];
        };

        programs.gh = {
          enable = true;
          settings.git_protocol = "ssh";
          extensions = [ pkgs.gh-markdown-preview ];
        };

        programs.git.enable = true;

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
          ping = "${pkgs.gping}/bin/gping";
        };

        programs.atuin = {
          enable = true;
          flags = [ "--disable-up-arrow" ];
          settings = {
            auto_sync = false;
            update_check = false;
            search_mode = "fuzzy";
            filter_mode = "host";
            secrets_filter = true;
            style = "compact";
            inline_height = 16;
          };
          enableZshIntegration = true;
          enableBashIntegration = true;
        };

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

        programs.plasma = {
          fonts =
            let
              font = {
                family = "JetBrainsMono Nerd Font";
                pointSize = 10;
              };
            in
            {
              general = font;
              menu = font;
              toolbar = font;
              windowTitle = font;
              fixedWidth = font // {
                family = "JetBrainsMono Nerd Font Mono";
              };
              small = font // {
                pointSize = 8;
              };
            };
        };
      };
  };
}
