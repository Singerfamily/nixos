# INFO: zsh Home-manager module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.aeon.cli.shell.zsh = {
    enable = mkOption {
      description = "Whether to enable ZSH, a new type of shell";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf config.aeon.cli.shell.zsh.enable {
    programs = {
      zsh = {
        enable = true;
        package = pkgs.zsh;

        # environmentVariables =
        #   let
        #     escapedVariables =
        #       { }
        #       |> lib.recursiveUpdate config.home.sessionVariables
        #       |> builtins.mapAttrs (_: value: toString value);
        #     badVariables = [
        #       # HACK: This one is set to something weird, and having it
        #       # present seems to break the cursor in some apps, like the Zen browser.
        #       "XCURSOR_PATH"
        #       "LD_LIBRARY_PATH"
        #     ];
        #   in
        #   builtins.removeAttrs escapedVariables badVariables;

        shellAliases = {
          lsa = "ls -a";
          cat = "${pkgs.bat}/bin/bat";
          btm = "${pkgs.bottom}/bin/btm --battery";
          ip = "ip --color=always";
          duf = "${pkgs.duf}/bin/duf -theme ansi";
          # tree = "erd --config tree";
          # sz = "erd --config sz";
        };

        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        initExtra = ''
          cp ~/.zsh_history ~/.zsh_history.bak
          strings ~/.zsh_history.bak > ~/.zsh_history
          fc -R ~/.zsh_history

          export XDG_DATA_HOME="$HOME/.local/share"
          eval "$(tailscale completion zsh)"
        '';

        shellAliases = {
          ll = "ls -l";
          la = "ls -la";
          update = "sudo nixos-rebuild switch --flake $HOME";
        };

        plugins = [
          {
            name = "powerlevel10k";
            src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
            file = "powerlevel10k.zsh-theme";
          }
          {
            name = "powerlevel10k-config";
            src = lib.cleanSource ".";
            file = "p10k.zsh";
          }
        ];

        oh-my-zsh = {
          enable = true;
          plugins = [
            "git"
            "kubectl"
          ];
        };
      };
    };
  };
}
