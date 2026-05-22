{ den, inputs, ... }:
{
  den.homes.x86_64-linux.esinger = { };
  den.aspects.esinger = {
    includes = [
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")
    ];

    user = {
      name = "esinger";
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
          # srm
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
          # netdiscover
          # nmap
          # rustscan
          # wakeonlan

          # System
          # file
          pciutils
          usbutils
          smartmontools
          # kondo
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

        programs.git = {
          enable = true;
          signing.format = "ssh";
          settings = {
            commit.gpgSign = true;
            tag.gpgSign = true;
            user.signingKey = "~/.ssh/id_ed25519.pub";
            gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";

            init.defaultBranch = "main";

            pull.rebase = true;
            push.autoSetupRemote = true;

            pager.difftool = true;

            diff.tool = "difftastic";
            diff.sopsdiffer.textconv = "sops -d --config /dev/null";
            difftool.prompt = false;
            difftool.difftastic.cmd = "${pkgs.difftastic}/bin/difft $LOCAL $REMOTE";

            alias = {
              "dff" = "difftool";
              "fap" = "fetch --all -p";
              "rm-merged" =
                "for-each-ref --format '%(refname:short)' refs/heads | grep -v master | xargs git branch -D";
              "recents" =
                "for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'";
            };

          };
          ignores = [
            ".DS_Store"
            "*.swp"
            ".direnv"
            ".envrc"
            ".envrc.local"
            "**/*local*"
            ".env"
            ".env.local"
            ".jj"
            "devshell.toml"
            ".tool-versions"
            "/.github/chatmodes"
            "/.github/instructions"
            "*.key"
            "target"
            "result"
            "out"
            "old"
            "*~"
            ".aider*"
            ".crush*"
          ];
          attributes = [
            "secrets/*.yaml diff=sopsdiffer"
            "secrets/*.json diff=sopsdiffer"
            "secrets/*.ini diff=sopsdiffer"
            "secrets/*.env diff=sopsdiffer"
          ];
          includes = [ ]; # standalone; no host-specific gitconfig includes needed
          lfs.enable = true;
        };

        programs.delta.enable = true;
        programs.delta.options = {
          line-numbers = true;
          side-by-side = false;
        };

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
