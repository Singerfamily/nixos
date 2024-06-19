{
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    microsoft-edge
  ];
}