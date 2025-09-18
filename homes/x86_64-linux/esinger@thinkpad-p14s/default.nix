{ pkgs, lib, ... }:
let
  dotfiles = builtins.path {
    path = ./dotfiles;
    name = "dotfiles";
  };
in
{
  home.stateVersion = "24.11";

  home.shellAliases = {
    ls = "${pkgs.eza}/bin/eza --group-directories-first --icons --color=auto";
    ll = "${pkgs.eza}/bin/eza -la --group-directories-first --icons --color=auto";
    lla = "${pkgs.eza}/bin/eza -la --group-directories-first --icons --color=auto --all";
    tree = "${pkgs.eza}/bin/eza --tree --level=3 --icons --color=auto";
    grep = "rg";
    cat = "bat";
    df = "duf";
    du = "dua";
    rm = "srm -v";
    pgrep = "pgrep -a"; # Show full command lines.
  };

  programs = {
    zsh = {
      # enable = true;
      plugins = [
        {
          name = "powerlevel10k-config";
          src = lib.cleanSource dotfiles;
          file = "p10k.zsh";
        }
      ];
    };

    git = {
      enable = true;
      userName = "LeaderbotX400";
      userEmail = "34589843+LeaderbotX400@users.noreply.github.com";
      attributes = [
        "secrets/*.{yaml,json,ini,env} diff=sopsdiffer"
      ];

      extraConfig = {
        diff.sopsdiffer.textconv = "sops -d --config /dev/null";
      };
    };

    eza = {
      enable = true;
      git = true;
      enableZshIntegration = true;
    };

    # vscode = {
    #   enable = true;
    # };

    lazydocker.enable = true;

    onedrive = {
      enable = true;
    };

    nh = {
      enable = true;
      flake = "/home/esinger/projects/nixos";
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
    };
  };

  # snowfall = {
  #   apps = {
  #     discord.enable = true;
  #   };
  #   cli = {
  #     atuin.enable = true;
  #     eza = {
  #       enable = true;
  #     };
  #   };

  #   games.minecraft.enable = true;

  #   user = {
  #     fullName = "Eric Singer";
  #     # email = "eric@singerfamily.ca";
  #   };

  #   dev = {
  #     dotnet.enable = true;
  #     js.enable = true;
  #   };
  #   flatpak = {
  #     enable = true;
  #     packages = [
  #       "com.microsoft.Edge"
  #       "com.spotify.Client"
  #       "org.libreoffice.LibreOffice"
  #     ];
  #   };
  # };

  # home.packages = with pkgs; [
  #   jetbrains.datagrip
  #   # jetbrains.rider
  #   # microsoft-edge
  # ];
}
