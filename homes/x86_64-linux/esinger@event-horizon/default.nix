{
  pkgs,
  ...
}:
{
  imports = [
    ./plasma.nix
    ../esinger
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
    # apps = {
    #   discord.enable = true;
    # };

    dev = {
      dotnet.enable = true;
      js.enable = true;

      rust.enable = true;
      go.enable = true;
    };
    flatpak = {
      enable = true;
      packages = [
        "com.microsoft.Edge"
        "com.spotify.Client"
        "org.libreoffice.LibreOffice"
        "dev.vencord.Vesktop"
      ];
    };
  };

  home.packages = with pkgs; [
    jetbrains.datagrip
    jetbrains.rust-rover
    jetbrains.goland
  ];
}
