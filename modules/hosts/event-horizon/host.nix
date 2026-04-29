{ den, ... }:
{
  den.hosts.x86_64-linux.event-horizon.users.esinger = { };

  den.aspects.event-horizon = {
    includes = with den.aspects; [
      kernel-cachy
      gpu-amd
      bluetooth
      sound
      plasma
      docker
      ssh
      flatpak
      steam
      ai-tools
      opencode
      gemini-cli
      ollama
      tailscale
      netbird
      sops
      compat
      crypto
      tpm
      vscode-server

      printing
    ];

  };
}
