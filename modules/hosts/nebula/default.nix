{ den, lib, ... }:
let
  esingerKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIConMjdymJ8/2DplJAz/nsy2iqF/DHbWXH0yRm2jslQN esinger@event-horizon";
in
{
  den.hosts.x86_64-linux.nebula.users.esinger = { };

  den.aspects.nebula = {
    includes = with den.aspects; [
      profile-server
      profile-managed
      networking
    ];

    nixos = _: {
      services.qemuGuest.enable = true;

      users.users.esinger.openssh.authorizedKeys.keys = [ esingerKey ];

      # Recovery path: if SSSD/Authentik is offline, esinger's UID lookup is
      # broken, or the local users database is wedged, root SSH with the
      # admin's key is the break-glass console. Belt-and-braces alongside the
      # `recovery` local-only account (modules/aspects/auth/recovery-account.nix).
      users.users.root.openssh.authorizedKeys.keys = [ esingerKey ];
      services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";

      # nebula is the testing host — allow wheel to sudo without a password
      # so iteration via `nixos-rebuild --target-host` doesn't need a TTY.
      security.sudo.extraRules = [
        {
          groups = [ "wheel" ];
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
