# Home provisioning for LDAP/Authentik-backed users on managed hosts.
#
# An LDAP user is unknown at build time, so home-manager's NixOS module
# (which is keyed to a build-time username) can never manage them. Instead
# we build STANDALONE home-manager closures — one per "portable" user, baked
# into the system closure — and activate the matching one at session start.
#
# A portable user is any directory under hm/users/. Each contributes:
#   hm/users/<name>/shell.nix     always applied (shell-only, headless-safe)
#   hm/users/<name>/desktop.nix   applied only on graphical hosts (optional)
# plus the shared hm/base/{shell,desktop}.nix layers. Headless hosts (servers,
# WSL) never pull the desktop layer or import plasma-manager — shell only.
#
# Activation runs as a systemd USER service ordered before the graphical
# session, so Plasma waits for the known-state home to be written. It is
# wired with `Wants` (via wantedBy), not `Requires` — a failed or slow
# activation logs and is skipped, never blocking login (fail-open + timeout).
{ inputs, lib, ... }:
let
  portableUsers = builtins.attrNames (
    lib.filterAttrs (_: t: t == "directory") (builtins.readDir ../../../hm/users)
  );
in
{
  den.aspects.ldap-home = {
    nixos =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      let
        graphical = config.services.desktopManager.plasma6.enable or false;

        # Build the standalone HM activation package for one portable user,
        # composing only the layers valid for this host's class.
        mkActivation =
          username:
          let
            userDir = ../../../hm/users + "/${username}";
            desktopFile = userDir + "/desktop.nix";
            shellLayers = [
              {
                home.username = username;
                home.homeDirectory = "/home/${username}";
                home.stateVersion = "26.05";
              }
              ../../../hm/base/shell.nix
              (userDir + "/shell.nix")
            ];
            # On a graphical host every portable user gets the base Plasma
            # known-state; a per-user desktop.nix is layered on if present.
            # Headless hosts get none of this — plasma-manager is never even
            # imported there.
            desktopLayers = lib.optionals graphical (
              [
                inputs.plasma-manager.homeModules.plasma-manager
                ../../../hm/base/desktop.nix
              ]
              ++ lib.optional (builtins.pathExists desktopFile) desktopFile
            );
          in
          (inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = shellLayers ++ desktopLayers;
          }).activationPackage;

        # Session-start activation. Acts ONLY on pure-LDAP users: someone who
        # has logged in but has NO local /etc/passwd entry. Local/declared
        # accounts (their HM is owned by the NixOS home-manager module) are
        # skipped, as are users with no portable config. The /etc/passwd test
        # is deliberate — `getent -s sss` cannot load the SSSD NSS plugin from
        # inside a systemd user service, so service-mode lookups are unusable
        # here; absence from /etc/passwd is the reliable "this is an LDAP user"
        # signal.
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

        # One built HM generation per portable user — on-disk, offline.
        environment.etc = builtins.listToAttrs (
          map (u: {
            name = "ldap-hm/${u}";
            value.source = mkActivation u;
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
