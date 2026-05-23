{ lib, ... }:
{
  den.aspects.openbao-secrets = {
    # -------------------------------------------------------------------------
    # NixOS module: system-level secrets + aggregation of all user secrets
    # into the vault-agent's template list.
    # -------------------------------------------------------------------------
    nixos =
      { pkgs, config, lib, ... }:
      let
        # System secrets declared directly on the NixOS config.
        sysTemplates = lib.mapAttrsToList (
          _name: sCfg: {
            destination = sCfg.path;
            perms = sCfg.mode;
            error_on_missing_key = false;
            command = "${pkgs.coreutils}/bin/chown ${sCfg.owner}:${sCfg.group} ${sCfg.path}";
            contents = ''{{ with secret "secret/data/${sCfg.baoPath}" }}{{ .Data.data.${sCfg.field} }}{{ end }}'';
          }
        ) config.openbao.secrets;

        # User secrets gathered from every home-manager user on this host.
        # The homeManager sub-module (below) computes each secret's path.
        # vault-agent (running as root) renders the file and chowns it.
        userTemplates = lib.concatLists (
          lib.mapAttrsToList (
            username: hmCfg:
            lib.mapAttrsToList (
              _name: sCfg: {
                destination = sCfg.path;
                perms = sCfg.mode;
                error_on_missing_key = false;
                command = "${pkgs.coreutils}/bin/chown ${username}:${username} ${sCfg.path}";
                contents = ''{{ with secret "secret/data/${sCfg.baoPath}" }}{{ .Data.data.${sCfg.field} }}{{ end }}'';
              }
            ) (hmCfg.openbao.secrets or { })
          ) (config.home-manager.users or { })
        );

        allUserDirs = lib.unique (
          lib.concatLists (
            lib.mapAttrsToList (
              username: hmCfg:
              lib.mapAttrsToList (
                _name: sCfg: "d ${builtins.dirOf sCfg.path} 0700 ${username} ${username} -"
              ) (hmCfg.openbao.secrets or { })
            ) (config.home-manager.users or { })
          )
        );
      in
      {
        options.openbao.secrets = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule (
              { name, ... }:
              {
                options = {
                  baoPath = lib.mkOption {
                    type = lib.types.str;
                    description = "KV path under secret/data/ in the nixos namespace (e.g. system/myapp/token).";
                  };
                  field = lib.mkOption {
                    type = lib.types.str;
                    default = "value";
                    description = "Field within the KV secret's data map to render.";
                  };
                  owner = lib.mkOption {
                    type = lib.types.str;
                    default = "root";
                  };
                  group = lib.mkOption {
                    type = lib.types.str;
                    default = "root";
                  };
                  mode = lib.mkOption {
                    type = lib.types.str;
                    default = "0400";
                  };
                  path = lib.mkOption {
                    type = lib.types.str;
                    default = "/run/openbao-secrets/${name}";
                    description = "Destination path on disk; readable at eval time for use in other options.";
                  };
                };
              }
            )
          );
          default = { };
          description = "System-level secrets rendered by the vault-agent to /run/openbao-secrets/<name>.";
        };

        config = {
          openbao.extraTemplates = sysTemplates ++ userTemplates;

          systemd.tmpfiles.rules =
            [ "d /run/openbao-secrets 0755 root root -" ]
            ++ lib.unique (
              lib.mapAttrsToList (
                _name: sCfg:
                "d ${builtins.dirOf sCfg.path} 0700 ${sCfg.owner} ${sCfg.group} -"
              ) config.openbao.secrets
            )
            ++ allUserDirs;
        };
      };

    # -------------------------------------------------------------------------
    # Home-manager module: user-level secret declarations.
    # path defaults to /run/openbao-secrets/<username>/<name> — computable at
    # eval time so other HM options can reference config.openbao.secrets.<name>.path.
    # -------------------------------------------------------------------------
    homeManager =
      { config, lib, ... }:
      {
        options.openbao.secrets = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule (
              { name, ... }:
              {
                options = {
                  baoPath = lib.mkOption {
                    type = lib.types.str;
                    description = "KV path under secret/data/ in the nixos namespace (e.g. users/eric/github/pat).";
                  };
                  field = lib.mkOption {
                    type = lib.types.str;
                    default = "value";
                    description = "Field within the KV secret's data map to render.";
                  };
                  mode = lib.mkOption {
                    type = lib.types.str;
                    default = "0400";
                  };
                  # config.home.username is from the HM module closure — no
                  # circular dep since it doesn't depend on openbao.secrets.
                  path = lib.mkOption {
                    type = lib.types.str;
                    default = "/run/openbao-secrets/${config.home.username}/${name}";
                    description = "Destination path on disk; readable at eval time for use in other options.";
                  };
                };
              }
            )
          );
          default = { };
          description = "User-level secrets rendered to /run/openbao-secrets/<username>/<name>.";
        };
      };
  };
}
