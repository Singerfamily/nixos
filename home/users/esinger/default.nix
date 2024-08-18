{ pkgs, ... }: {
  programs = {
    zsh.enable = true;
    git.enable = true;
    direnv.enable = true;
    kdeconnect = {
        enable = true;
        # package = pkgs.kdePackages.kdeconnect-kde;
    };
  };

  home = {
    programs = {
      git = {
        enable = true;
        userName = "LeaderbotX400";
        userEmail = "eric@singerfamily.ca";
      };

      zsh.enable = true;
      zoxide.enable = true;
      fzf.enable = true;
    };
  };

  users = {
    mutableUsers = true;

    users.esinger = {
      isNormalUser = true;
      name = "esinger";
      shell = pkgs.zsh;
      description = "Eric Singer";
      extraGroups = [
        "wheel"
        "video"
        "audio"
        "networkmanager"
        "tss"
      ];

      hashedPassword =
        "$y$j9T$mboI3SZPrs3PANp77OkRQ1$804/B42apAF5ef7J70Shkw7t3qmYKCZLx2xym1/hUH8";
    };
  };

  environment.systemPackages = with pkgs; [
    gh
    vscode
    microsoft-edge-dev
    zoxide
    fzf
  ];
}
