{
  pkgs,
  lib,
  config,
  ...
}:
let
  dotfiles = builtins.path {
    path = ./dotfiles;
    name = "dotfiles";
  };

  inherit (config.home) username;
in
{
  imports = [
    ./dotfiles/plasma.nix
  ];

  home.stateVersion = "24.11";

  home.shellAliases = lib.mkForce {
    ls = "eza --group-directories-first --color=auto --hyperlink";
    ll = "ls -la";
    lla = "ls -la --all";
    tree = "ls --tree --level=3";
    grep = "rg";
    cat = "bat";
    df = "duf";
    du = "dua";
    pgrep = "pgrep -a"; # Show full command lines.
  };

  programs = {
    zsh.plugins = [
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource dotfiles;
        file = "p10k.zsh";
      }
    ];

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

    vscode = {
      enable = true;
    };

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

  snowfall = {
    apps = {
      discord.enable = true;
    };
    cli = {
      atuin.enable = true;
      eza = {
        enable = true;
      };
    };

    games.minecraft.enable = true;

    user = {
      fullName = "Eric Singer";
      # email = "eric@singerfamily.ca";
    };

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
      ];
    };
  };

  sops = {
    secrets."ssh/${username}" = {
      path = "/home/${username}/.ssh/id_ed25519";
      mode = "0600";
    };

    secrets."keys/age" = {
      path = "/home/${username}/.config/sops/age/keys.txt";
      mode = "0600";
    };
  };

  home.activation = {
    genSshPubKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${pkgs.openssh}/bin/ssh-keygen -y -f /home/${username}/.ssh/id_ed25519 > /home/${username}/.ssh/id_ed25519.pub
    '';
  };

  home.packages = with pkgs; [
    jetbrains.datagrip
    jetbrains.rust-rover
    jetbrains.goland
    # jetbrains.rider
    # microsoft-edge
  ];
}
