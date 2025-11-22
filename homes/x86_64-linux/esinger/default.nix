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
      fullName = mkDefault "Eric Singer";
      # email = mkDefault  "eric@singerfamily.ca";
    };
  };

  home.stateVersion = "25.05";

  home.shellAliases = {
    ls = mkDefault "${pkgs.eza}/bin/eza --group-directories-first --color=auto --hyperlink";
    ll = mkDefault "ls -la";
    lla = mkDefault "ls -la --all";
    tree = mkDefault "ls --tree --level=3";
    grep = mkDefault "rg";
    cat = mkDefault "bat";
    df = mkDefault "duf";
    du = mkDefault "dua";
    pgrep = mkDefault "pgrep -a"; # Show full command lines.
    dc = mkDefault "docker compose";
    run = mkDefault "NIXPKGS_ALLOW_UNFREE=1 nix run --impure nixpkgs#$1";
  };

  programs = {
    zsh.plugins = mkDefault [
      {
        name = mkDefault "powerlevel10k-config";
        src = mkDefault lib.cleanSource dotfiles;
        file = mkDefault "p10k.zsh";
      }
    ];

    git = {
      enable = mkDefault true;
      userName = mkDefault "LeaderbotX400";
      userEmail = mkDefault "34589843+LeaderbotX400@users.noreply.github.com";
      attributes = mkDefault [
        "secrets/*.{yaml,json,ini,env} diff=sopsdiffer"
      ];

      extraConfig = {
        diff.sopsdiffer.textconv = mkDefault "sops -d --config /dev/null";
      };
    };

    eza = {
      enable = mkDefault true;
      git = mkDefault true;
      enableZshIntegration = mkDefault true;
    };

    lazydocker.enable = mkDefault true;

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
