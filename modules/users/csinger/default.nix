{ den, ... }:
{
  den.aspects.csinger = {
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
      den.aspects.dev-python
      den.aspects.dev-rust
      den.aspects.dev-embedded
      den.aspects.atuin
      den.aspects.sops
    ];

    # NixOS-level: set user password from sops
    nixos =
      { config, ... }:
      let
        secretsPath = ../../../secrets;
      in
      {
        sops.secrets."csinger/password" = {
          key = "password";
          neededForUsers = true;
          sopsFile = secretsPath + "/users/csinger.yaml";
        };
        users.users.csinger = {
          hashedPasswordFile = config.sops.secrets."csinger/password".path;
          extraGroups = [
            "networkmanager"
            "builders"
            "kvm"
            "libvirtd"
            "audio"
            "video"
            "tss"
            "docker"
          ];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIConMjdymJ8/2DplJAz/nsy2iqF/DHbWXH0yRm2jslQN"
          ];
        };
      };

    homeManager =
      { ... }:
      {
        programs.git.settings = {
          user.name = "clintsinger";
          user.email = "clint@singerfamily.ca";
        };

        programs.nh = {
          enable = true;
          flake = "/etc/nixos";
          clean = {
            enable = true;
            extraArgs = "--keep-since 4d --keep 3";
          };
        };

        home.shellAliases = {
          pgrep = "pgrep -a";
          dc = "docker compose";
          run = "NIXPKGS_ALLOW_UNFREE=1 nix run";
        };

        # Sops user secrets
        sops.secrets = {
        };
      };

    # clint-pc specific config for csinger
    provides.clint-pc.homeManager =
      { pkgs, ... }:
      let
        wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Autumn/contents/images/2560x1440.jpg";
      in
      {
        home.packages = with pkgs; [
          kara
          jetbrains.rider
          jetbrains.datagrip
          jetbrains.rust-rover
          jetbrains.pycharm
          jetbrains.goland
          android-studio
          gimp
          davinci-resolve
          slack
          obs-studio
          vlc
          inkscape
          neovim
          speedtest-cli
          remmina
          nmap

          # Kubernetes / infrastructure
          talosctl
          dapr-cli

          # WinApps / Windows interop dependencies
          dialog
          freerdp
          iproute2
          libnotify
          openssl
          nss.tools

          # Testing
          python3Packages.pytest
        ];

        home.sessionVariables = {
          OPENOCD_PATH = "${pkgs.openocd}";
          OPENOCD_SCRIPTS_PATH = "${pkgs.openocd}/share/openocd/scripts";
        };

        # Plasma per-user config
        programs.plasma = {
          workspace.wallpaper = wallpaper;

          fonts = {
            fixedWidth = {
              family = "JetBrainsMono Nerd Font Mono";
              pointSize = 10;
            };
            general = {
              family = "Noto Sans";
              pointSize = 10;
            };
            menu = {
              family = "Noto Sans";
              pointSize = 10;
            };
            small = {
              family = "Noto Sans";
              pointSize = 8;
            };
            toolbar = {
              family = "Noto Sans";
              pointSize = 10;
            };
            windowTitle = {
              family = "Noto Sans";
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
            timeout = 10;
          };

          hotkeys.commands.launch-edge = {
            name = "Launch Edge";
            key = "Meta+Shift+E";
            command = "flatpak run --branch=stable --arch=x86_64 --command=/app/bin/edge --file-forwarding com.microsoft.Edge @@u %U @@";
          };

          panels = [
            {
              screen = 0;
              floating = false;
              height = 34;
              lengthMode = "fill";
              location = "bottom";
              opacity = "translucent";
              widgets = [
                "org.kde.plasma.panelspacer"
                "org.kde.plasma.kickoff"
                { name = "org.kde.plasma.icontasks"; }
                "org.kde.plasma.panelspacer"
                {
                  systemTray.items = {
                    showAll = false;
                    shown = [
                      "org.kde.plasma.notifications"
                      "org.kde.plasma.networkmanagement"
                      "org.kde.plasma.volume"
                      "org.kde.plasma.bluetooth"
                    ];
                  };
                }
                {
                  name = "org.kde.plasma.digitalclock";
                  config.Appearance.use24hFormat = 2;
                }
              ];
            }
            {
              screen = 1;
              floating = false;
              height = 34;
              lengthMode = "fill";
              location = "bottom";
              opacity = "translucent";
              widgets = [
                {
                  name = "org.dhruv8sh.kara";
                  config = {
                    general = {
                      spacing = 3;
                      type = 1;
                    };
                    type1 = {
                      fixedLen = 3;
                      labelSource = 0;
                    };
                  };
                }
                "org.kde.plasma.panelspacer"
                "org.kde.plasma.kickoff"
                { name = "org.kde.plasma.icontasks"; }
                "org.kde.plasma.panelspacer"
                {
                  systemTray.items = {
                    showAll = false;
                    shown = [
                      "org.kde.plasma.notifications"
                      "org.kde.plasma.networkmanagement"
                      "org.kde.plasma.volume"
                      "org.kde.plasma.bluetooth"
                    ];
                  };
                }
                {
                  name = "org.kde.plasma.digitalclock";
                  config.Appearance.use24hFormat = 2;
                }
              ];
            }
          ];

          configFile = {
            baloofilerc."Basic Settings"."Indexing-Enabled" = false;
            kwinrc."General"."FreeFloating" = true;
            dolphinrc = {
              CompactMode = {
                IconSize = 22;
                PreviewSize = 32;
              };
              DetailsMode = {
                IconSize = 22;
                PreviewSize = 16;
              };
            };
          };
        };

        # Flatpak packages
        services.flatpak.packages = [
          "com.spotify.Client"
          "org.libreoffice.LibreOffice"
        ];
      };
  };
}
