{ den, ... }:
{
  den.aspects.git.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        difftastic
        git-filter-repo
      ];

      home.file.".ssh/allowed_signers".text = "";

      programs.gh = {
        enable = true;
        settings.git_protocol = "ssh";
        extensions = [ pkgs.gh-markdown-preview ];
      };

      programs.git = {
        enable = true;
        signing.format = "ssh";
        settings = {
          # TODO: move these to home-specific configs
          # user.name = "<NAME>";
          # user.email = "<EMAIL>";
          # github.user = "<USERNAME>";
          # gitlab.user = "<USERNAME>";
          # core.editor = "vim";

          commit.gpgSign = true;
          tag.gpgSign = true;
          user.signingKey = "~/.ssh/id_ed25519.pub";
          gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
          init.defaultBranch = "main";
          pull.rebase = true;
          pager.difftool = true;
          diff.tool = "difftastic";
          diff.sopsdiffer.textconv = "sops -d --config /dev/null";
          difftool.prompt = false;
          difftool.difftastic.cmd = "${pkgs.difftastic}/bin/difft $LOCAL $REMOTE";
          alias = {
            "dff" = "difftool";
            "fap" = "fetch --all -p";
            "rm-merged" =
              "for-each-ref --format '%(refname:short)' refs/heads | grep -v master | xargs git branch -D";
            "recents" =
              "for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'";
          };
        };
        ignores = [
          ".DS_Store"
          "*.swp"
          ".direnv"
          ".envrc"
          ".envrc.local"
          ".env"
          ".env.local"
          ".jj"
          "devshell.toml"
          ".tool-versions"
          "/.github/chatmodes"
          "/.github/instructions"
          "*.key"
          "target"
          "result"
          "out"
          "old"
          "*~"
          ".aider*"
          ".crush*"
          "CRUSH.md"
          "GEMINI.md"
          "CLAUDE.md"
        ];
        attributes = [
          "secrets/*.yaml diff=sopsdiffer"
          "secrets/*.json diff=sopsdiffer"
          "secrets/*.ini diff=sopsdiffer"
          "secrets/*.env diff=sopsdiffer"
        ];
        includes = [ ];
        lfs.enable = true;
      };

      programs.delta.enable = true;
      programs.delta.options = {
        line-numbers = true;
        side-by-side = false;
      };
    };
}