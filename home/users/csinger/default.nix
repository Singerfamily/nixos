{ pkgs, ... }:
{
  programs = {
    zsh.enable = true;
    git.enable = true;
    direnv.enable = true;
  };

  users = {
    mutableUsers = true;

    users.csinger = {
      isNormalUser = true;
      name = "csinger";
      shell = pkgs.zsh;
      description = "Clint Singer";
      extraGroups = [
        "wheel"
        "video"
        "audio"
        "networkmanager"
        "tss"
      ];

      hashedPassword = "$y$j9T$mboI3SZPrs3PANp77OkRQ1$804/B42apAF5ef7J70Shkw7t3qmYKCZLx2xym1/hUH8";
    };
  };

  environment.systemPackages = with pkgs; [
    gh
    vscode
    microsoft-edge-dev
    zoxide
    fzf
    kubectl
  ];
}
