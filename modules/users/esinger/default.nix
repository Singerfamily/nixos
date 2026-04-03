{ den, ... }:
{
  den.aspects.esinger = {
    includes = [
      den.provides.primary-user
      (den.provides.user-shell "zsh")
      den.aspects.zsh
      den.aspects.fzf
      den.aspects.git
      den.aspects.plasma-full
      den.aspects.discord
      den.aspects.vscode
      den.aspects.onedrive
      den.aspects.dev-nix
      den.aspects.dev-dotnet
      den.aspects.dev-js
      den.aspects.dev-java
      den.aspects.dev-c
      den.aspects.dev-rust
      den.aspects.dev-go
      den.aspects.sops
      den.aspects.determinate
    ];

    homeManager =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      {
        programs.git.settings = {
          user.name = "LeaderbotX400";
          user.email = "34589843+LeaderbotX400@users.noreply.github.com";
          github.user = "LeaderbotX400";
        };

        programs.nh = {
          enable = true;
          flake = "/home/esinger/projects/nixos";
          clean = {
            enable = true;
            extraArgs = "--keep-since 4d --keep 3";
          };
        };

        programs.lazydocker.enable = true;

        home.packages = [ pkgs.bitwarden-desktop ];

        # Claude Code MCP servers
        home.file.".claude/claude_desktop_config.json".text = builtins.toJSON {
          mcpServers = {
            nixos = {
              command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
            };
            markitdown = {
              command = "docker";
              args = [ "run" "--rm" "-i" "mcp/markitdown:latest" ];
            };
          };
        };

        home.shellAliases = {
          pgrep = "pgrep -a";
          dc = "docker compose";
          run = "NIXPKGS_ALLOW_UNFREE=1 nix run";
        };

        # Sops user secrets
        sops.secrets =
          let
            home = config.home.homeDirectory;
          in
          {
            "ssh/privateKey" = {
              path = "${home}/.ssh/id_ed25519";
              mode = "0600";
            };

            "ssh/publicKey" = {
              path = "${home}/.ssh/id_ed25519.pub";
              mode = "0600";
            };

            "keys/age" = {
              path = "${home}/.config/sops/age/keys.txt";
              mode = "0600";
            };
          };
      };

    # event-horizon specific config for esinger
    provides.event-horizon.homeManager =
      { pkgs, lib, ... }:
      let
        wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Kay/contents/images_dark/5120x2880.png";
      in
      {
        # Dev tools for this host
        home.packages = with pkgs; [
          jetbrains.datagrip
          jetbrains.rust-rover
          jetbrains.goland
          # android-studio
          microsoft-edge
          uv
        ];

        # Plasma per-user config (panels, wallpaper, fonts, input)
        programs.plasma = {
          workspace.wallpaper = wallpaper;

          fonts = {
            fixedWidth = {
              family = "JetBrainsMono Nerd Font Mono";
              pointSize = 10;
            };
            general = {
              family = "JetBrainsMono Nerd Font";
              pointSize = 10;
            };
            menu = {
              family = "JetBrainsMono Nerd Font";
              pointSize = 10;
            };
            small = {
              family = "JetBrainsMono Nerd Font";
              pointSize = 8;
            };
            toolbar = {
              family = "JetBrainsMono Nerd Font";
              pointSize = 10;
            };
            windowTitle = {
              family = "JetBrainsMono Nerd Font";
              pointSize = 10;
            };
          };

          input = {
            keyboard = {
              repeatDelay = 250;
              repeatRate = 40;
            };
            mice = [
              {
                accelerationProfile = "none";
                name = "Razer USA, Ltd Razer Naga V2 Pro";
                productId = "00a7";
                vendorId = "1532";
              }
            ];
          };

          kscreenlocker = {
            appearance.wallpaper = wallpaper;
            autoLock = true;
            timeout = 15;
          };

          hotkeys.commands.launch-edge = {
            name = "Launch Edge";
            key = "Meta+Shift+E";
            command = "${pkgs.microsoft-edge}/bin/microsoft-edge";
          };

          panels = [
            {
              location = "bottom";
              height = 36;
              screen = "all";
              widgets = [
                {
                  name = "org.kde.plasma.kickoff";
                  config.General = {
                    icon = "nix-snowflake-white";
                    alphaSort = true;
                  };
                }
                {
                  iconTasks.launchers = [
                    "applications:org.kde.konsole.desktop"
                    "applications:org.kde.dolphin.desktop"
                    "applications:microsoft-edge.desktop"
                    "applications:code.desktop"
                    "applications:vesktop.desktop"
                    "applications:steam.desktop"
                  ];
                }
                "org.kde.plasma.panelspacer"
                {
                  systemTray.items = {
                    showAll = false;
                    shown = [
                      "org.kde.plasma.volume"
                      "org.kde.plasma.bluetooth"
                    ];
                  };
                }
                {
                  digitalClock = {
                    calendar.firstDayOfWeek = "sunday";
                    time.format = "24h";
                  };
                }
              ];
            }
          ];

          configFile = {
            klipperrc.General.MaxClipItems = 1000;
            kwinrc.Plugins.krohnkiteEnabled = true;
            kwinrc."Script-krohnkite" = {
              screenGapBetween = 3;
              screenGapBottom = 3;
              screenGapLeft = 3;
              screenGapRight = 3;
              screenGapTop = 3;
            };
          };
        };

        # Flatpak packages
        services.flatpak.packages = [
          "com.spotify.Client"
          "org.libreoffice.LibreOffice"
          "org.prismlauncher.PrismLauncher"
        ];
      };
  };
}
