# Passwordless sudo via the forwarded SSH agent (pam_ssh_agent_auth) — the
# companion to the OIDC device-code login (see [[oidc-login]] / oidc-login.nix).
#
# A device-code login provides no password, and SSSD only caches a password
# after a *password* login, so an OIDC-logged-in user has no credential for a
# password sudo prompt. Rather than force a phone/browser device dance on every
# `sudo` (miserable for high-frequency re-auth), authenticate sudo against the
# key already in the user's forwarded SSH agent — the same OpenBao-issued
# identity that got them onto the box. Forward your agent (`ssh -A`) and sudo is
# passwordless; no agent key match falls through to the normal password path.
#
# How it wires up: the `sudo` PAM service already defaults `sshAgentAuth = true`
# upstream, so enabling the global toggle inserts pam_ssh_agent_auth as the
# first (sufficient) auth method on sudo, and NixOS keeps SSH_AUTH_SOCK across
# the env_reset automatically. We only have to enable it and name a key file.
#
# The key file MUST be root-owned (pam_ssh_agent_auth runs as root and refuses
# user-writable files), so we use /etc/ssh/authorized_keys.d/%u — the location
# NixOS already populates from users.users.<u>.openssh.authorizedKeys.keys —
# rather than ~/.ssh/authorized_keys. "Key authorizes SSH login" therefore also
# means "key authorizes sudo".
#
# Opt-in: add `sudo-ssh-agent` to a host's includes. NOPASSWD break-glass for
# the local `recovery` account must be kept alongside (see the nebula host) so a
# wedged agent/IdP never locks sudo out entirely.
_: {
  den.aspects.sudo-ssh-agent = {
    nixos = _: {
      security.pam.sshAgentAuth = {
        enable = true;
        authorizedKeysFiles = [ "/etc/ssh/authorized_keys.d/%u" ];
      };
    };
  };
}
