# Pull the host's configuration from the central flake repo: a weekly
# unattended upgrade plus an on-demand `update` command. Both fetch the
# private singerfamily/nixos flake over GitHub, authenticated by the token
# the OpenBao agent renders into /etc/nix/access-tokens.conf (see
# modules/aspects/services/openbao-agent.nix).
{ ... }:
let
  # The branch the fleet tracks. NOTE: currently `feat/ldap` while the LDAP
  # work lands — switch this to `main` once that is merged.
  flakeRef = "github:singerfamily/nixos/feat/ldap";
in
{
  den.aspects.auto-update = {
    nixos =
      { config, pkgs, ... }:
      let
        target = "${flakeRef}#${config.networking.hostName}";
      in
      {
        # Unattended weekly upgrade — Sunday 00:00. `persistent` catches up a
        # run missed because the host was off. A failed build never switches,
        # so a broken commit cannot brick the host.
        system.autoUpgrade = {
          enable = true;
          flake = target;
          dates = "Sun *-*-* 00:00:00";
          flags = [ "--refresh" ];
          persistent = true;
        };

        # `update` — pull latest config and rebuild now. Re-exec under sudo so
        # it works from any unprivileged shell.
        environment.systemPackages = [
          (pkgs.writeShellScriptBin "update" ''
            exec sudo nixos-rebuild switch --flake "${target}" --refresh "$@"
          '')
        ];
      };
  };
}
