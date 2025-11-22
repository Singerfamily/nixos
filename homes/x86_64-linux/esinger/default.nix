{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  dotfiles = builtins.path {
    path = ./dotfiles;
    name = "dotfiles";
  };

  inherit (config.home) username;
in
{
  snowfall = {
    user = {
      fullName = "Eric Singer";
      # email =  "eric@singerfamily.ca";
    };
  };

  home.stateVersion = "25.05";

  home.shellAliases = {
    ls = "${pkgs.eza}/bin/eza --group-directories-first --color=auto --hyperlink";
    ll = "ls -la";
    lla = "ls -la --all";
    tree = "ls --tree --level=3";
    grep = "rg";
    cat = "bat";
    df = "duf";
    du = "dua";
    pgrep = "pgrep -a"; # Show full command lines.
    dc = "docker compose";
    run = "NIXPKGS_ALLOW_UNFREE=1 nix run --impure nixpkgs#$1";
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

    lazydocker.enable = true;

    nh = {
      enable = true;
      flake = "/home/esinger/projects/nixos";
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
    };
  };

  sops.secrets = {
    "ssh/privateKey" = {
      path = "/home/${username}/.ssh/id_ed25519";
      mode = "0600";
    };

    "ssh/publicKey" = {
      path = "/home/${username}/.ssh/id_ed25519.pub";
      mode = "0600";
    };

    "keys/age" = {
      path = "/home/${username}/.config/sops/age/keys.txt";
      mode = "0600";
    };
  };
}
