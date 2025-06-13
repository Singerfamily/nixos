{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nixfmt
    nixd
  ];
}