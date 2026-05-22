{ den, ... }:
{
  den.aspects.profile-desktop = {
    includes = with den.aspects; [
      networking
      gpu
      plasma
      plasma-power
      bluetooth
      cups
      flatpak
      docker
      vscode-server
      kdeconnect
      determinate
    ];
  };
}
