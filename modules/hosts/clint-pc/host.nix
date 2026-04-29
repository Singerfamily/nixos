{ den, ... }:
{
  den.hosts.x86_64-linux.clint-pc.users.csinger = { };

  den.aspects.clint-pc = {
    includes = with den.aspects; [
      gpu-nvidia-prime
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
      vscode-server

      browsers
      media-tools
      playwright
      azure-devops
    ];
  };
}
