# Home provisioning for LDAP/Authentik-backed users on managed hosts.
#
# An LDAP user is unknown at build time, so home-manager's NixOS module
# (keyed to a build-time username) can never manage them. Instead we reuse
# the flake's own standalone home configs: every den user that declares
# `den.homes.<arch>.<name>` is exported as `homeConfigurations.<name>` (and
# an activatable `packages.<arch>.<name>`, runnable via `nix run .#<name>`).
#
# Each home's activationPackage is baked into the system closure as
# /etc/ldap-hm/<name>; the matching one is activated at session start. A
# username with no corresponding den home is simply skipped.
#
# Activation runs as a systemd USER service ordered before the graphical
# session, so Plasma waits for the home to be written. It is wired with
# `Wants` (via wantedBy), not `Requires` — a failed or slow activation logs
# and is skipped, never blocking login (fail-open + timeout).
{ self, ... }:
let
  # Portable users = every standalone home the flake exports. Sourced
  # straight from den — the home config IS the den user aspect.
  homes = self.homeConfigurations or { };
  portableUsers = builtins.attrNames homes;
in
{
  den.aspects.ldap-home = {
    nixos =
      { pkgs, config, lib, ... }:
      let
        # Session-start activation. Acts ONLY on pure-LDAP users: someone who
        # has logged in but has NO local /etc/passwd entry. Local/declared
        # accounts (their HM is owned by the NixOS home-manager module) are
        # skipped, as are users with no exported home. The /etc/passwd test
        # is deliberate — `getent -s sss` cannot load the SSSD NSS plugin
        # from inside a systemd user service, so absence from /etc/passwd is
        # the reliable "this is an LDAP user" signal.
        activateScript = pkgs.writeShellScript "ldap-home-activate" ''
          set -u
          user=$(${pkgs.coreutils}/bin/id -un) || exit 0

          # Local/declared account → leave it to the NixOS home-manager module.
          if ${pkgs.gnugrep}/bin/grep -q "^$user:" /etc/passwd; then
            exit 0
          fi

          gen="/etc/ldap-hm/$user"
          [ -e "$gen/activate" ] || exit 0

          echo "ldap-home: activating home-manager generation for $user"
          ${pkgs.coreutils}/bin/timeout 110 "$gen/activate" \
            || echo "ldap-home: activation for $user failed/timed out — continuing"
          exit 0
        '';
      in
      {
        # home-manager activation registers the generation through the nix
        # daemon, so LDAP login users need daemon access. They are not in
        # `wheel`; the Authentik `linux` posix group is what gates their
        # shell login, so grant the daemon to that group. This list option
        # merges with the global allowed-users (modules/aspects/core/nix.nix).
        nix.settings.allowed-users = [ "@linux" ];

        # Create the home directory on first login.
        security.pam.services = {
          login.makeHomeDir = true;
          sshd.makeHomeDir = true;
        }
        // lib.optionalAttrs config.services.displayManager.sddm.enable {
          sddm.makeHomeDir = true;
        };

        # One exported home generation per portable user — on-disk, offline.
        environment.etc = builtins.listToAttrs (
          map (u: {
            name = "ldap-hm/${u}";
            value.source = homes.${u}.activationPackage;
          }) portableUsers
        );

        # Apply at session start, before Plasma. wantedBy (not requiredBy) =
        # fail-open; TimeoutStartSec caps any hang.
        systemd.user.services.ldap-home-manager = {
          description = "Apply home-manager generation for LDAP-provisioned users";
          wantedBy = [
            "graphical-session-pre.target"
            "default.target"
          ];
          before = [ "graphical-session-pre.target" ];
          path = [
            pkgs.nix
            pkgs.coreutils
            pkgs.gnugrep
          ];
          serviceConfig = {
            Type = "oneshot";
            TimeoutStartSec = "120";
            ExecStart = "${activateScript}";
          };
        };
      };
  };
}
