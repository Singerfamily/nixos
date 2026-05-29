{ den, lib, ... }:
let
  ericKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIConMjdymJ8/2DplJAz/nsy2iqF/DHbWXH0yRm2jslQN eric@event-horizon";
in
{
  den.hosts.x86_64-linux.nebula.users.eric = { };

  den.aspects.nebula = {
    includes = with den.aspects; [
      profile-server
      profile-managed
      networking
      # Test bed for the opt-in OIDC device-code login (alongside LDAP, which
      # stays the default). Exposed over SSH below via keyboard-interactive.
      oidc-login
      # Passwordless sudo via the forwarded SSH agent, so OIDC-logged-in admins
      # (who have no cached password) can still elevate.
      sudo-ssh-agent
      # Plasma + SDDM, so we can verify graphical login works against SSSD/LDAP
      # before rolling the managed auth stack onto the real desktops. OIDC
      # device-code is intentionally NOT wired into the SDDM greeter (the greeter
      # is a single password field) — graphical login uses the LDAP password.
      plasma
    ];

    nixos = _: {
      services.qemuGuest.enable = true;

      users.users.eric.openssh.authorizedKeys.keys = [ ericKey ];

      # Recovery path: if SSSD/Authentik is offline, eric's UID lookup is
      # broken, or the local users database is wedged, root SSH with the
      # admin's key is the break-glass console. Belt-and-braces alongside the
      # `recovery` local-only account (modules/aspects/auth/recovery-account.nix).
      users.users.root.openssh.authorizedKeys.keys = [ ericKey ];
      services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";

      # Expose the OIDC device-code login over SSH without disturbing the
      # cert-based path that deploys rely on. `publickey keyboard-interactive`
      # are alternatives (whitespace = either suffices), so a normal `ssh` still
      # logs in via its CA-signed cert; forcing the keyboard-interactive method
      # (`ssh -o PreferredAuthentications=keyboard-interactive eric@nebula`)
      # routes through PAM and triggers the device-code prompt.
      services.openssh.settings.KbdInteractiveAuthentication = true;
      services.openssh.extraConfig = ''
        AuthenticationMethods publickey keyboard-interactive
      '';

      # Break-glass: the local `recovery` account keeps NOPASSWD sudo so a
      # wedged SSH agent or unreachable IdP can never lock sudo out, and remote
      # `nixos-rebuild --target-host recovery@… --sudo` deploys stay TTY-free.
      # Everyone else in wheel (e.g. eric) now authenticates sudo through
      # pam_ssh_agent_auth (see the sudo-ssh-agent aspect) — forward your agent.
      security.sudo.extraRules = [
        {
          users = [ "recovery" ];
          commands = [
            {
              command = "ALL";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
  };
}
