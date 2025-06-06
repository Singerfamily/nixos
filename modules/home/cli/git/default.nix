# INFO: Home-manager Git module

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.cli.git = {
    enable = mkOption {
      description = "Whether to enable Git VCS";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf config.snowfall.cli.git.enable {
    programs.git = {
      enable = true;
      # userName = "<username>";
      # userEmail = "<hash>+<username>@users.noreply.github.com";

      extraConfig = {
        init.defaultBranch = "main";
        gpg.format = "ssh";
        commit.gpgSign = true;
        tag.gpgSign = true;
        user.signingKey = "~/.ssh/id_ed25519.pub";
        gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      };

      lfs.enable = true;
      difftastic = {
        enable = true;
        background = "dark";
      };
    };

    home.file.".ssh/allowed_signers".text = '''';

    programs.gh = {
      enable = true;
      settings.git_protocol = "ssh";
      extensions = with pkgs; [
        gh-markdown-preview
      ];
    };

    home.packages = with pkgs; [
      git-filter-repo
    ];
  };
}
