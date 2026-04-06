{ den, ... }:
{
  den.hosts.x86_64-linux.clint-pc.users.csinger = { };

  den.aspects.clint-pc = {
    includes = [
      den.aspects.gpu-intel
      den.aspects.gpu-nvidia
      den.aspects.bluetooth
      den.aspects.sound
      den.aspects.plasma
      den.aspects.docker
      den.aspects.ssh
      den.aspects.flatpak
      den.aspects.qemu
      den.aspects.ai-tools
      den.aspects.tailscale
      den.aspects.sops
      den.aspects.determinate
      den.aspects.compat
      den.aspects.crypto
      den.aspects.tpm
    ];

    nixos =
      { lib, pkgs, config, ... }:
      {
        # Hardware
        boot.initrd.availableKernelModules = [
          "vmd"
          "xhci_pci"
          "ahci"
          "thunderbolt"
          "nvme"
          "usb_storage"
          "usbhid"
          "sd_mod"
        ];
        boot.kernelModules = [ "kvm-intel" ];
        boot.extraModprobeConfig = "options kvm_intel nested=1";

        # Filesystems
        fileSystems."/" = {
          device = "/dev/disk/by-uuid/5ce2ae63-604b-4e22-9923-4dc1f479ade6";
          fsType = "ext4";
        };
        fileSystems."/boot" = {
          device = "/dev/disk/by-uuid/1454-A232";
          fsType = "vfat";
        };
        fileSystems."/mnt/data" = {
          device = "/dev/disk/by-uuid/f54eca10-f82e-4531-a24f-af500a7e45bf";
          fsType = "ext4";
        };
        swapDevices = [
          { device = "/dev/disk/by-uuid/9e72bc8a-7a48-4c4d-b180-6cd63a6aa1bd"; }
        ];

        # NVIDIA PRIME for dual GPU
        hardware.nvidia.prime = {
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };

        # SSH server with relaxed MACs for KASM
        services.openssh.settings.Macs = [
          "hmac-sha2-256-etm@openssh.com"
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256"
          "hmac-sha2-512"
        ];

        # Sunshine game streaming
        services.sunshine = {
          enable = true;
          autoStart = true;
          capSysAdmin = true;
          openFirewall = true;
        };

        # Ensure Sunshine can capture input devices
        services.udev.extraRules = ''
          KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
        '';

        # GNOME Remote Desktop — works with Wayland via Pipewire (no GNOME desktop needed)
        services.gnome.gnome-remote-desktop.enable = true;
        xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
        xdg.portal.config.common = {
          "org.freedesktop.impl.portal.ScreenCast" = "gnome";
          "org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
        };

        # SMB mount
        fileSystems."/mnt/backup" = {
          device = "//10.200.0.3/clint";
          fsType = "cifs";
          options = [
            "x-systemd.automount"
            "noauto"
            "x-systemd.idle-timeout=60"
            "x-systemd.device-timeout=5s"
            "x-systemd.mount-timeout=5s"
            "credentials=/etc/nixos/.secret-smb"
          ];
        };

        # Open RDP port
        networking.firewall.allowedTCPPorts = [ 3389 ];

        # Wayland
        environment.sessionVariables.NIXOS_OZONE_WL = "1";

        # Azure DevOps defaults for AI agents (az devops CLI reads these automatically)
        environment.variables = {
          AZURE_DEVOPS_ORG = "https://dev.azure.com/nueradev";
          AZURE_DEVOPS_PROJECT = "ProjectVicious";
          # Playwright — point to nix-managed browser binaries
          PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
          PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
          # libvirt default connection
          LIBVIRT_DEFAULT_URI = "qemu:///system";
        };

        # ASP.NET Core development certificate
        security.pki.certificateFiles = [
          ./aspnetcore-dev-cert.crt
        ];

        # System packages
        environment.systemPackages = with pkgs; [
          cifs-utils
          lsof
          google-chrome
          firefox
          microsoft-edge

          # Playwright browsers (system-level, alongside other browsers)
          playwright-driver.browsers
          chromium

          # Image/video processing tools
          imagemagick
          ffmpeg
          pngquant
          optipng
          (python3.withPackages (ps: [ ps.pillow ]))

          # Node.js (provides npx)
          nodejs
        ];

        # OpenCode background server (Codex / OpenAI)
        # Runs as csinger so it can access opencode's auth store
        sops.secrets."opencode_server_username" = { };
        sops.secrets."opencode_server_password" = { };

        system.activationScripts.opencode-servers = {
          text = ''
            mkdir -p /etc/opencode/codex
            cat > /etc/opencode/codex/opencode.json <<'OCEOF'
            { "model": "openai/gpt-5.3-codex" }
            OCEOF
          '';
        };

        # Generate ws config with the codex server profile
        system.activationScripts.ws-config = {
          deps = [ "setupSecrets" ];
          text = ''
            WS_DIR="/home/csinger/.config/ws"
            mkdir -p "$WS_DIR"

            OC_USER="$(tr -d '\n' < ${config.sops.secrets."opencode_server_username".path} 2>/dev/null || echo opencode)"
            OC_PASS="$(tr -d '\n' < ${config.sops.secrets."opencode_server_password".path} 2>/dev/null || echo "")"

            cat > "$WS_DIR/config.json" <<WSEOF
            {
              "servers": [
                {"name": "codex", "url": "http://localhost:43102", "username": "$OC_USER", "password": "$OC_PASS", "default": true}
              ]
            }
            WSEOF

            chown -R csinger:users "$WS_DIR"
            chmod 600 "$WS_DIR/config.json"
          '';
        };

        # Install Claude skills from this repo on every rebuild
        system.activationScripts.install-claude-skills = ''
          SKILLS_DST="/home/csinger/.claude/skills"
          mkdir -p "$SKILLS_DST"
          chown -R csinger:users "/home/csinger/.claude"
        '';

        systemd.services.opencode-codex =
          let
            envScript = pkgs.writeShellScript "opencode-codex-env" ''
              for i in $(seq 1 30); do
                [ -f ${config.sops.secrets."opencode_server_username".path} ] && break
                sleep 1
              done
              {
                echo "OPENCODE_SERVER_USERNAME=$(cat ${config.sops.secrets."opencode_server_username".path})"
                echo "OPENCODE_SERVER_PASSWORD=$(cat ${config.sops.secrets."opencode_server_password".path})"
              } > /run/opencode-codex.env
              chmod 644 /run/opencode-codex.env
            '';
          in
          {
            description = "OpenCode server (codex)";
            wantedBy = [ "multi-user.target" ];
            after = [ "network.target" ];
            serviceConfig = {
              ExecStartPre = "+" + envScript;
              ExecStart = "${pkgs.opencode}/bin/opencode serve --hostname 127.0.0.1 --port 43102";
              EnvironmentFile = "/run/opencode-codex.env";
              Environment = [ "OPENCODE_CONFIG=/etc/opencode/codex/opencode.json" ];
              User = "csinger";
              Group = "users";
              Restart = "always";
              RestartSec = "5s";
              StartLimitIntervalSec = 120;
              StartLimitBurst = 10;
              NoNewPrivileges = true;
              PrivateTmp = true;
            };
          };

        # Restart opencode periodically to pick up refreshed OAuth tokens
        systemd.timers.opencode-codex-refresh = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "6h";
            OnUnitActiveSec = "6h";
            Unit = "opencode-codex-refresh.service";
          };
        };

        systemd.services.opencode-codex-refresh = {
          description = "Restart opencode-codex to pick up fresh OAuth tokens";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "/run/current-system/sw/bin/systemctl restart opencode-codex.service";
          };
        };
      };
  };
}
