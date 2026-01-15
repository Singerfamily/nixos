{
  pkgs,
  ...
}:
{
  imports = [
    ./plasma.nix

  ];

  programs = {
    vscode = {
      enable = true;
    };

    onedrive = {
      enable = true;
    };
  };

  snowfall = {
    apps = {
      discord.enable = true;
    };

    dev = {
      dotnet.enable = true;
      js.enable = true;
      java.enable = true;

      rust.enable = true;
      go.enable = true;

      jetbrains.enable = true;
    };
    flatpak = {
      enable = true;
      packages = [
        # "com.microsoft.Edge"
        "com.spotify.Client"
        "org.libreoffice.LibreOffice"
        "org.prismlauncher.PrismLauncher"
      ];
    };
  };

  home.packages = with pkgs; [
    jetbrains.datagrip
    jetbrains.rust-rover
    jetbrains.goland
    android-studio
    microsoft-edge
  ];
}
