{ den, ... }:
{
  den.hosts.x86_64-linux.clint-pc.users.csinger = { };

  den.aspects.clint-pc = {
    includes = with den.aspects; [
      gpu-intel
      gpu-nvidia
      bluetooth
      sound
      plasma
      docker
      ssh
      flatpak
      qemu
      ai-tools
      opencode
      gemini-cli
      ollama
      tailscale
      sops
      determinate
      compat
      crypto
      tpm
      sunshine
      gnome-remote-desktop
      opencode-server
      samba-client
    ];

    nixos =
      { pkgs, ... }:
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

        # SMB mount — tooling comes from samba-client aspect
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

        # Install Claude skills from this repo on every rebuild
        system.activationScripts.install-claude-skills = ''
          SKILLS_DST="/home/csinger/.claude/skills"
          mkdir -p "$SKILLS_DST"
          chown -R csinger:users "/home/csinger/.claude"
        '';
      };
  };
}
