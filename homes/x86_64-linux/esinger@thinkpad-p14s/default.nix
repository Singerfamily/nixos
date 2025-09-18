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
  home.stateVersion = "25.05";

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
}
