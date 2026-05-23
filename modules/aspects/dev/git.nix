{ den, ... }:
{
  den.default.includes = [ den.aspects.git ];

  den.aspects.git = {
    home-manager =
      {
        config,
        lib,
        ...
      }:
      {
        config = lib.mkIf config.programs.git.enable {

          programs.git = {
            signing.format = "ssh";
            settings = {
              commit.gpgSign = true;
              tag.gpgSign = true;
              user.signingKey = "~/.ssh/id_ed25519.pub";
              gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";

              init.defaultBranch = "main";

              pull.rebase = true;
              push.autoSetupRemote = true;

              alias = {
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
              "**/*local*"
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
            ];
            includes = [ ]; # standalone; no host-specific gitconfig includes needed
            lfs.enable = true;
          };
        };
      };
  };
}
